function [ class ] = fun_SGR(ens_trainX,ens_trainY,indexes,Ydata_all_DR,lambda,gamma,mu,sz)

ln = length(ens_trainY);
C = max(ens_trainY);

Yl = zeros(ln,C);
for i = 1:C
    ind = find(ens_trainY == i);
    Yl(ind',i) = 1;
    clear ind;
end
%% SR by sunsal
Z = sunsal(ens_trainX,Ydata_all_DR,'lambda',lambda,'ADDONE','yes','POSITIVITY','yes', ...
    'AL_iters',100,'TOL', 1e-8, 'verbose','yes');
Z = Z';

T = Z(indexes,:)'*Z(indexes,:);
rL = T-T*diag(sum(Z(indexes,:)).^-1)*T;
LM = Z(indexes,:)'*Z(indexes,:)+gamma*rL;
RM = Z(indexes,:)'*Yl;
A = (LM+1e-6*eye(ln))\RM;
F = Z*A;
F1 = F*diag(sum(F).^-1);
p=F1';


%% graphcut by Matlab wrapper;
%        http://www.wisdom.weizmann.ac.il/~bagon/matlab.html
%------------------------------------------------------------------
Dc = reshape((log(p+eps))',[sz(1) sz(2) C]);%(log(p+eps)-H)
% energy for each class0
Sc = ones(C) - eye(C);
% spatialy varying part
gch = GraphCut('open', -Dc, mu*Sc);
[gch class] = GraphCut('expand',gch);
gch = GraphCut('close', gch);
class=double(class)+1;

end

