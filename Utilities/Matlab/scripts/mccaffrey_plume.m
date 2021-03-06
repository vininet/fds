% McDermott
% 7-7-14
% mccaffrey_plume.m

close all
clear all

plot_style
Font_Interpreter='latex';

Q = [14.4 21.7 33.0 44.9 57.5]; % kW [14.4 21.7 33.0 44.9 57.5]
g = 9.8;
rho = 1.18;
cp = 1;
T0 = 273.15 + 20;

DS = (Q/(rho*cp*T0*sqrt(g))).^(2/5) % m

repo = '/Volumes/rmcdermo/GitHub/FireModels_rmcdermo/fds/';

%datadir = '../../Validation/McCaffrey_Plume/FDS_Output_Files/';
datadir = [repo,'Validation/McCaffrey_Plume/Current_Results/'];
plotdir = [repo,'Manuals/FDS_Validation_Guide/SCRIPT_FIGURES/McCaffrey_Plume/'];

%chid = {'McCaffrey_14_kW_11','McCaffrey_22_kW_11','McCaffrey_33_kW_11','McCaffrey_45_kW_11','McCaffrey_57_kW_11'};
chid = {'McCaffrey_14_kW_21','McCaffrey_22_kW_21','McCaffrey_33_kW_21','McCaffrey_45_kW_21','McCaffrey_57_kW_21'};
%chid = {'McCaffrey_14_kW_45','McCaffrey_22_kW_45','McCaffrey_33_kW_45','McCaffrey_45_kW_45','McCaffrey_57_kW_45'};
mark = {'ko','k+','k^','ksq','kd'};
n_chid = length(chid);

% McCaffrey plume correlations

zq = logspace(-2,0,100);

for i=1:length(zq)
    if zq(i)<0.08
        vq(i) = 6.84*zq(i)^0.5;
        Tq(i) = 800*zq(i)^0;
    elseif zq(i)>=0.08 & zq(i)<=0.2
        vq(i) = 1.93*zq(i)^0;
        Tq(i) = 63*zq(i)^(-1);
    elseif zq(i)>0.2
        vq(i) = 1.12*zq(i)^(-1/3);
        Tq(i) = 21.6*zq(i)^(-5/3);
    end
end

% Baum and McCaffrey plume correlations (in terms of D*)
% 2nd IAFSS, pp. 129-148

zs = logspace(-2,1,100);
n = [1/2 0 -1/3];
A = [2.18 2.45 3.64];
B = [2.91 3.81 8.41];

for i=1:length(zs)
    if zs(i)<1.32
        j=1;
    elseif zs(i)>=1.32 & zs(i)<=3.3
        j=2;
    elseif zs(i)>3.3
        j=3;
    end
    us(i) = A(j)*zs(i)^n(j);
    Ts(i) = B(j)*zs(i)^(2*n(j)-1);
end

figure
set(gca,'Units',Plot_Units)
set(gca,'Position',[Plot_X Plot_Y Plot_Width Plot_Height])

hh(n_chid+1)=loglog(zq,vq,'b--','linewidth',2); hold on
% % for Baum scaling use:
% xmin = 0.2;
% xmax = 20;
% ymin = 1;
% ymax = 3.5;
% for McCaffrey 1979 scaling use:
xmin = 0.008;
xmax = 0.6;
ymin = 0.2;
ymax = 2.5;
axis([xmin xmax ymin ymax])
%grid on
xlabel('$z/Q^{2/5}$ (m $\cdot$ kW$^{-2/5}$ )','FontSize',Label_Font_Size,'Interpreter',Font_Interpreter)
ylabel('$V/Q^{1/5}$ (m $\cdot$ s$^{-1}$ $\cdot$ kW$^{-1/5}$ )','FontSize',Label_Font_Size,'Interpreter',Font_Interpreter)
% xlabel('$z^* = z/D^*$','FontSize',Label_Font_Size,'Interpreter',Font_Interpreter)
% ylabel('$v^* = v/\sqrt{g D^*} $','FontSize',Label_Font_Size,'Interpreter',Font_Interpreter)

% FDS results velocity

for i=1:n_chid
    M = importdata([datadir,chid{i},'_line.csv'],',',2);
    z = M.data(:,find(strcmp('Height',M.colheaders)));
    dz = z(2)-z(1);
    z = z + dz/2; % use with "wvel" for staggered storage location
    v = M.data(:,find(strcmp('wvel',M.colheaders)));

    % McCaffrey 1979 scaling
    zq_fds = z./Q(i)^(2/5);
    vq_fds = v./Q(i)^(1/5);

    % Baum and McCaffrey 2nd IAFSS scaling
    % zs_fds = z./DS(i);
    % vs_fds = v./sqrt(g*DS(i));

    hh(i)=loglog(zq_fds,vq_fds,mark{i});
end

set(gca,'FontName',Font_Name)
set(gca,'FontSize',Label_Font_Size)

leg_key = {'14.4 kW','21.7 kW','33.0 kW','44.9 kW','57.5 kW','$A(z^*\,)^n$'};
lh = legend(hh,leg_key,'location','southeast');
set(lh,'Interpreter',Font_Interpreter)
set(lh,'FontSize',Key_Font_Size)

% add version string if file is available

Git_Filename = [datadir,'McCaffrey_14_kW_11_git.txt'];
addverstr(gca,Git_Filename,'loglog')

% print to pdf

set(gcf,'Visible',Figure_Visibility);
set(gcf,'Units',Paper_Units);
set(gcf,'PaperSize',[Paper_Width Paper_Height]);
set(gcf,'Position',[0 0 Paper_Width Paper_Height]);
print(gcf,'-dpdf',[plotdir,'McCaffrey_Velocity_Correlation'])


% FDS results temperature rise

figure
set(gca,'Units',Plot_Units)
set(gca,'Position',[Plot_X Plot_Y Plot_Width Plot_Height])

hh(n_chid+1)=loglog(zq,Tq,'r--','linewidth',2); hold on

% % Baum scaling:
% xmin = 0.1;
% xmax = 20;
% ymin = 0.1;
% ymax = 5;
% McCaffrey scaling
xmin = 0.008;
xmax = 0.6;
ymin = 100;
ymax = 1600;
axis([xmin xmax ymin ymax])
%grid on
xlabel('$z/Q^{2/5}$ (m $\cdot$ kW$^{-2/5}$ )','FontSize',Label_Font_Size,'Interpreter',Font_Interpreter)
ylabel('$\Delta T$ ($^\circ$C)','FontSize',Label_Font_Size,'Interpreter',Font_Interpreter)
% xlabel('$z^* = z/D^*$','FontSize',Label_Font_Size,'Interpreter',Font_Interpreter)
% ylabel('$\Theta^* = (T-T_0)/T_0$','FontSize',Label_Font_Size,'Interpreter',Font_Interpreter)

for i=1:n_chid
    M = importdata([datadir,chid{i},'_line.csv'],',',2);
    z = M.data(:,find(strcmp('Height',M.colheaders)));
    T = M.data(:,find(strcmp('tmp',M.colheaders))) + 273.15;
    zq_fds = z./Q(i)^(2/5);
    hh(i)=loglog(zq_fds,T-T0,mark{i});
    % hh(i)=loglog(z./DS(i),(T-T0)/T0,mark{i});
end

set(gca,'FontName',Font_Name)
set(gca,'FontSize',Label_Font_Size)

leg_key = {'14.4 kW','21.7 kW','33.0 kW','44.9 kW','57.5 kW','$B(z^*\,)^{2n-1}$'};
lh = legend(hh,leg_key,'location','southwest');
set(lh,'Interpreter',Font_Interpreter)
set(lh,'FontSize',Key_Font_Size)

% add version string if file is available

Git_Filename = [datadir,'McCaffrey_14_kW_11_git.txt'];
addverstr(gca,Git_Filename,'loglog')

% print to pdf

set(gcf,'Visible',Figure_Visibility);
set(gcf,'Units',Paper_Units);
set(gcf,'PaperSize',[Paper_Width Paper_Height]);
set(gcf,'Position',[0 0 Paper_Width Paper_Height]);
print(gcf,'-dpdf',[plotdir,'McCaffrey_Temperature_Correlation'])


% Velocity profile in the plume

figure
set(gca,'Units',Plot_Units)
set(gca,'Position',[Plot_X Plot_Y Plot_Width Plot_Height])

z = 1;
chid = {'McCaffrey_22_kW_11','McCaffrey_22_kW_21','McCaffrey_22_kW_45'};
mark = {'kd','k^','ksq'};
for i=1:length(chid)
    M = importdata([datadir,chid{i},'_line.csv'],',',2);
    x = M.data(:,find(strcmp('Radius',M.colheaders)));
    V = M.data(:,find(strcmp('wx_p',M.colheaders)));
    V0 = V(find(x==0));
    hh(i)=plot(x/z,V/V0,mark{i}); hold on
end

z = 1.25;
chid = {'McCaffrey_45_kW_11','McCaffrey_45_kW_21','McCaffrey_45_kW_45'};
mark = {'kd','k^','ksq'};
for i=1:length(chid)
    M = importdata([datadir,chid{i},'_line.csv'],',',2);
    x = M.data(:,find(strcmp('Radius',M.colheaders)));
    V = M.data(:,find(strcmp('wx_p',M.colheaders)));
    V0 = V(find(x==0));
    hh(length(chid)+i)=plot(x/z,V/V0,mark{i},'MarkerFaceColor','k'); hold on
end

x = linspace(0,.3,100);
a1 = 0.16; % see Fig. 6, McCaffrey (1979)
a2 = 0.14;
a3 = 0.18;
v1 = exp(-(5/6/a1*x).^2);
v2 = exp(-(5/6/a2*x).^2);
v3 = exp(-(5/6/a3*x).^2);
hh(2*length(chid)+1)=plot(x,v1,'k-');
hh(2*length(chid)+2)=plot(x,v2,'k--');
hh(2*length(chid)+3)=plot(x,v3,'k-.');

set(gca,'FontName',Font_Name)
set(gca,'FontSize',Label_Font_Size)

axis([0 .35 0 1.2])
xlabel('$x/z$','FontSize',Label_Font_Size,'Interpreter',Font_Interpreter)
ylabel('$V/V_0$','FontSize',Label_Font_Size,'Interpreter',Font_Interpreter)

leg_key = {'22 kW 11','22 kW 21','22 kW 45',...
           '45 kW 11','45 kW 21','45 kW 45',...,
           '$\alpha=0.14$','$\alpha=0.16$','$\alpha=0.18$'};
lh=legend(hh,leg_key,'location','northeast');
set(lh,'Interpreter',Font_Interpreter)
set(lh,'FontSize',Key_Font_Size)

xt = .05;
yt = 1.1;
text(xt,yt,'Plume','FontSize',Title_Font_Size,'Interpreter',Font_Interpreter,'FontName',Font_Name)

% add version string if file is available

Git_Filename = [datadir,'McCaffrey_14_kW_11_git.txt'];
addverstr(gca,Git_Filename,'linear')

% print to pdf

set(gcf,'Visible',Figure_Visibility);
set(gcf,'Units',Paper_Units);
set(gcf,'PaperSize',[Paper_Width Paper_Height]);
set(gcf,'Position',[0 0 Paper_Width Paper_Height]);
print(gcf,'-dpdf',[plotdir,'McCaffrey_Velocity_Profile_Plume'])


% Velocity profile in the intermittent region

figure
set(gca,'Units',Plot_Units)
set(gca,'Position',[Plot_X Plot_Y Plot_Width Plot_Height])

clear hh

z = 0.5;
x_1oe = 0.46*(z/Q(2)^(2/5)) + 0.013*sqrt(Q(2));
chid = {'McCaffrey_22_kW_11','McCaffrey_22_kW_21','McCaffrey_22_kW_45'};
mark = {'kd','k^','ksq'};
for i=1:length(chid)
    M = importdata([datadir,chid{i},'_line.csv'],',',2);
    x = M.data(:,find(strcmp('Radius',M.colheaders)));
    V = M.data(:,find(strcmp('wx_i',M.colheaders)));
    V0 = V(find(x==0));
    hh(i)=plot(x/x_1oe,V/V0,mark{i}); hold on
end

z = 0.75;
x_1oe = 0.46*(z/Q(4)^(2/5)) + 0.013*sqrt(Q(4));
chid = {'McCaffrey_45_kW_11','McCaffrey_45_kW_21','McCaffrey_45_kW_45'};
mark = {'kd','k^','ksq'};
for i=1:length(chid)
    M = importdata([datadir,chid{i},'_line.csv'],',',2);
    x = M.data(:,find(strcmp('Radius',M.colheaders)));
    V = M.data(:,find(strcmp('wx_i',M.colheaders)));
    V0 = V(find(x==0));
    hh(length(chid)+i)=plot(x/x_1oe,V/V0,mark{i},'MarkerFaceColor','k'); hold on
end

x = linspace(0,2,100);
v1 = exp(-x.^1.5);
hh(2*length(chid)+1)=plot(x,v1,'k-');

set(gca,'FontName',Font_Name)
set(gca,'FontSize',Label_Font_Size)

axis([0 3 0 1.2])
xlabel('$x/x_{1/e}$','FontSize',Label_Font_Size,'Interpreter',Font_Interpreter)
ylabel('$V/V_0$','FontSize',Label_Font_Size,'Interpreter',Font_Interpreter)

leg_key = {'22 kW 11','22 kW 21','22 kW 45',...
           '45 kW 11','45 kW 21','45 kW 45',...
           '$n=3/2$'};
lh=legend(hh,leg_key,'location','northeast');
set(lh,'Interpreter',Font_Interpreter)
set(lh,'FontSize',Key_Font_Size)

xt = .5;
yt = 1.1;
text(xt,yt,'Intermittent','FontSize',Title_Font_Size,'Interpreter',Font_Interpreter,'FontName',Font_Name)

% add version string if file is available

Git_Filename = [datadir,'McCaffrey_14_kW_11_git.txt'];
addverstr(gca,Git_Filename,'linear')

% print to pdf

set(gcf,'Visible',Figure_Visibility);
set(gcf,'Units',Paper_Units);
set(gcf,'PaperSize',[Paper_Width Paper_Height]);
set(gcf,'Position',[0 0 Paper_Width Paper_Height]);
print(gcf,'-dpdf',[plotdir,'McCaffrey_Velocity_Profile_Intermittent'])


% Velocity profile in the flame region

figure
set(gca,'Units',Plot_Units)
set(gca,'Position',[Plot_X Plot_Y Plot_Width Plot_Height])

clear hh

z = 0.125;
x_1oe = 0.46*(z/Q(2)^(2/5)) + 0.013*sqrt(Q(2));
chid = {'McCaffrey_22_kW_11','McCaffrey_22_kW_21','McCaffrey_22_kW_45'};
mark = {'kd','k^','ksq'};
for i=1:length(chid)
    M = importdata([datadir,chid{i},'_line.csv'],',',2);
    x = M.data(:,find(strcmp('Radius',M.colheaders)));
    V = M.data(:,find(strcmp('wx_f',M.colheaders)));
    V0 = V(find(x==0));
    hh(i)=plot(x/x_1oe,V/V0,mark{i}); hold on
end

z = 0.25;
x_1oe = 0.46*(z/Q(4)^(2/5)) + 0.013*sqrt(Q(4));
chid = {'McCaffrey_45_kW_11','McCaffrey_45_kW_21','McCaffrey_45_kW_45'};
mark = {'kd','k^','ksq'};
for i=1:length(chid)
    M = importdata([datadir,chid{i},'_line.csv'],',',2);
    x = M.data(:,find(strcmp('Radius',M.colheaders)));
    V = M.data(:,find(strcmp('wx_f',M.colheaders)));
    V0 = V(find(x==0));
    hh(length(chid)+i)=plot(x/x_1oe,V/V0,mark{i},'MarkerFaceColor','k'); hold on
end

x = linspace(0,2,100);
v1 = exp(-x.^1.5);
v2 = exp(-x.^2);
hh(2*length(chid)+1)=plot(x,v1,'k-');
hh(2*length(chid)+2)=plot(x,v2,'k--');

set(gca,'FontName',Font_Name)
set(gca,'FontSize',Label_Font_Size)

axis([0 3 0 1.2])
xlabel('$x/x_{1/e}$','FontSize',Label_Font_Size,'Interpreter',Font_Interpreter)
ylabel('$V/V_0$','FontSize',Label_Font_Size,'Interpreter',Font_Interpreter)

leg_key = {'22 kW 11','22 kW 21','22 kW 45',...
           '45 kW 11','45 kW 21','45 kW 45',...
           '$n=3/2$','$n=2$'};
lh=legend(hh,leg_key,'location','northeast');
set(lh,'Interpreter',Font_Interpreter)
set(lh,'FontSize',Key_Font_Size)

xt = .5;
yt = 1.1;
text(xt,yt,'Flame','FontSize',Title_Font_Size,'Interpreter',Font_Interpreter,'FontName',Font_Name)

% add version string if file is available

Git_Filename = [datadir,'McCaffrey_14_kW_11_git.txt'];
addverstr(gca,Git_Filename,'linear')

% print to pdf

set(gcf,'Visible',Figure_Visibility);
set(gcf,'Units',Paper_Units);
set(gcf,'PaperSize',[Paper_Width Paper_Height]);
set(gcf,'Position',[0 0 Paper_Width Paper_Height]);
print(gcf,'-dpdf',[plotdir,'McCaffrey_Velocity_Profile_Flame'])

