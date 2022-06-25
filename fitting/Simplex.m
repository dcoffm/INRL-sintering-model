function fits = Simplex(seed,input,output,fhandle,ehandle,phandle,itmax)
% A general multivariate optimization algorithm

% Seed  - set of coefficients acting as an initial guess for the parameters to be fit
% input - other values from which the output is calculated
% output - the "true" or observed output that we are trying to fit to
% fhandle - handle to the function that computes output from input & parameters,
        % output = f(seed,input)
% ehandle - handle to the function that computes a magnitude of "error" between a test output and the observed output, such as RMS difference
        % err = e(output,out_test)
% phandle - handle to the function that plots/visualizes the fitting process, if desired
        % figHandles = phandle(output,out_test,figHandles)
        
% itmax - maximum number of iterations to perform the simplex algorithm


nCoeff = numel(seed); % Number of coeffients
xerror = zeros(1,nCoeff+1); % Squared error for each point

p = repmat(seed,[nCoeff+1 1]);
for k = 2:nCoeff+1
  p(k, k-1) = 1.1 * p(k, k-1);
end

if ~isempty(phandle)
    temp = fhandle(seed,input);
    figHandles = phandle(output,temp,[]);
end

moveOn = false;
ScalingRefresh = true; iter = 0;
while iter<itmax && moveOn==false
    [p,xerror,il,out_test,ScalingRefresh] = SimplexIt(p,xerror,input,output,ScalingRefresh,fhandle,ehandle);
	
	% Update plot
    if ~isempty(phandle)
        out_best = fhandle(p(il,:), input); % current best set of parameter values
        figHandles.iter = iter; % In case you want to plot the current iteration number or parameter values
        figHandles.seed = p(il,:);
        phandle(output,out_best,figHandles); % Send it to the provided plotting function 
    end
	iter=iter+1;
end

fits = p(il,:);

end

function [p,xerror,il,out_test, ScalingRefresh] = SimplexIt(p,xerror,input,output,ScalingRefresh,fhandle,ehandle)
alpha = 0.98; % Reflection factor
beta  = 1.97; % Expansion factor
gamma = 0.48; % Contraction factor
kappa = -1;	  % Scaling factor

if ScalingRefresh % Generate error values for all points
	for m = 1:size(p,1)
		out_test = fhandle(p(m,:),input);
		xerror(m) = ehandle(output,out_test);
	end
	ScalingRefresh=false;
end

% Main Loop:
[~,ih] = max(xerror); % Get points with highest/lowest error
[~,il] = min(xerror);

cent = (sum(p,1)-p(ih,:))./size(p,2); % Centroid point (amongst all but the highest error)
pr = (1+alpha)*cent - alpha*p(ih,:);  % Reflect the point with highest error
out_test = fhandle(pr,input);
erref = ehandle(output,out_test);   % Error for reflected point

% Determine what to do with reflected point:
flag = 0;
if erref <= xerror(ih); flag = 1; end % Reflection is good
if erref <  xerror(il); flag = 2; end % Reflection is so good that expansion should be tried
if erref >  xerror(ih); flag = 3; end % Reflection is not good

switch flag
case 0
    error('The provided error function produced a NaN value.');
case 1 % Stay with reflection
    p(ih,:) = pr;
    xerror(ih) = erref;
	
case 2 % Evaluate expansion possibility
	pex = beta*pr + (1-beta)*cent; % Expanded point
    out_test = fhandle(pex,input);
    erexp = ehandle(output,out_test); 
	
	if erexp < erref		% Go with expansion
		p(ih,:) = pex;
		xerror(ih) = erexp;
	else					% Go with reflection
		p(ih,:) = pr;
		xerror(ih) = erref;
	end
	
case 3 % Evaluate for contraction or scaling
	pc = (1-gamma)*cent + gamma*p(ih,:); % Contracted point
    out_test = fhandle(pc,input);
    ercon = ehandle(output,out_test);
	
	if ercon < xerror(ih)	    % Go with contraction
		p(ih,:) = pc;
		xerror(ih) = ercon;
	else						% Resort to scaling
		ScalingRefresh = true;
        p = p + kappa*( p(il,:) - p );
	end
end
end