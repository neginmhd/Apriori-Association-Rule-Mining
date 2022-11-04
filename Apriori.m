function [EndRules, Rs]=Apriori(T,MST,MCT)
    % Create Items Set
    ItemsArr=[];
    for i=1:numel(T)
        ItemsArr=union(ItemsArr,T{i});
    end
    ItemsArr=ItemsArr(:)';
    
    % 1st level Candidates
    C{1}=cell(1,numel(ItemsArr));
    count{1}=zeros(size(C{1}));
    for rIndex=1:numel(ItemsArr)
        C{1}{rIndex}=ItemsArr(rIndex);
        for i=1:numel(T)
            if IsContainedIn(C{1}{rIndex},T{i})
                count{1}(rIndex)=count{1}(rIndex)+1;
            end
        end
    end
    % 1st Level Frequent Patterns
    L{1}=C{1}(count{1}/numel(T)>=MST);

    % Initialize Counter
    k=1;

    % Iterations
    while ~isempty(L{k})

        b=[];
        for i=1:numel(L{k})
            b=union(b,L{k}{i});
        end
        b=b(:)';
        
        % (k+1)-th Level Candidates
        C{k+1}={};
        for i=1:numel(L{k})
            A=L{k}{i};
            for j=1:numel(b);
                if ~ismember(b(j),A)
                    New=[A b(j)];
                    Found=false;
                    for rIndex=1:numel(C{k+1})
                        if (numel(New)==numel(C{k+1}{rIndex}) && all(sort(New)==sort(C{k+1}{rIndex})))
                            Found=true;
                            break;
                        end
                    end
                    if ~Found
                        C{k+1}=[C{k+1} {New}];
                    end
                end
            end
        end
        
        % Calculate Patterns Counts
        count{k+1}=zeros(size(C{2}));
        for rIndex=1:numel(C{k+1})
            for i=1:numel(T)
                if IsContainedIn(C{k+1}{rIndex},T{i})
                    count{k+1}(rIndex)=count{k+1}(rIndex)+1;
                end
            end
        end
        
        % (k+1)-th Level Frequent Patterns
        L{k+1}=C{k+1}(count{k+1}/numel(T)>=MST);
        
        % Increment Counter
        k=k+1;

    end

    L=L(1:end-1);

    % Extract Rules
    Rs={};
    Supp=[];
    Conf=[];
    Lift=[];
    for k=2:numel(L)
        for i=1:numel(L{k})

            countL=0;
            for j=1:numel(T)
                if IsContainedIn(L{k}{i},T{j})
                    countL=countL+1;
                end
            end
            
            %
            A2=L{k}{i};
            n2=numel(A2);
            S=cell(2^n2-2,1);
            for i2=1:numel(S)
                f2=dec2binvec(i2);
                f2=[f2 zeros(1,n2-numel(f2))];
                S{i2}=A2(logical(f2));
            end
            %
            Q=S(end:-1:1);
            for rIndex=1:numel(S)
                Rs=[Rs; {S{rIndex} Q{rIndex}}];
                countS=0;
                countQ=0;
                for j=1:numel(T)
                    if IsContainedIn(S{rIndex},T{j})
                        countS=countS+1;
                    end
                    if IsContainedIn(Q{rIndex},T{j})
                        countQ=countQ+1;
                    end
                end
                Supp=[Supp; countL/numel(T)];
                Conf=[Conf; countL/countS];
                Lift=[Lift; countL/(countS*countQ/numel(T))];
            end
        end
    end
    
    % Sort According to Confidence Rate
    [Conf, SortOrder]=sort(Conf,'descend');
    Supp=Supp(SortOrder);
    Lift=Lift(SortOrder);
    Rs=Rs(SortOrder,:);
    for i=1:size(Rs)
        Rs{i,3}=Supp(i);
        Rs{i,4}=Conf(i);
        Rs{i,5}=Lift(i);
    end

    % Select Final Rules
    EndRules=Rs(Conf>=MCT & Lift>=1,:);

end

function b=IsContainedIn(A,B)
    b=all(ismember(A,B));
end
