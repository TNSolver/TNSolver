function plotfunc(func)
%plotfunc(func)
%
%  Description:
%
%    Plot a function from TNSolver func() structure to a PDF file without
%    displaying it.
%
%  Inputs:
%
%    func() - a single member of the func structure
%
%  Outputs:
%
%    a PDF file with the name of the function, as parsed from the input.
%
%==========================================================================

figure('Visible','off')
h = axes('Position',[0 0 1 1],'Visible','off');
axes('Position',[0.1 0.1 0.85 0.85])

switch func.type
  case 0  % constant
    X = linspace(0,1,10);
    Y(1:10) = func.data;
    plot(X,Y)
    title(['Constant Function: ' func.name],'Interpreter','none')
    xlabel('time')
    ylabel('f(t)')    
  case 1  % piecewise linear (table)
    X = linspace(func.data(1,1),func.data(end,1),1000);
    Y(1:1000) = interp1(func.data(:,1), func.data(:,2), X, 'linear');
    plot(X,Y)
    hold on
    plot(func.data(:,1),func.data(:,2),'o')
    title(['Piecewise Linear (Table) Time Function: ' func.name],'Interpreter','none')
    xlabel('time')
    ylabel('f(t)')
  case 2  % spline
    X = linspace(func.data(1,1),func.data(end,1),1000);
    Y(1:1000) = interp1(func.data(:,1), func.data(:,2), X, 'pchip');
    plot(X,Y)
    hold on
    plot(func.data(:,1),func.data(:,2),'o')
    title(['Spline Time Function: ' func.name],'Interpreter','none')
    xlabel('time')
    ylabel('f(t)')  
  otherwise
end

set(gcf,'CurrentAxes',h)
%text(0.95, 0.0, datestr(now,'mmmm dd, yyyy HH:MM AM'),  ...
%     'HorizontalAlignment', 'right',  ...
%     'VerticalAlignment', 'bottom',  ...
%     'FontSize', 8)

%saveas(gcf, func.name, 'png')   % PNG file format
saveas(gcf, func.name, 'pdf')   % PDF file format
