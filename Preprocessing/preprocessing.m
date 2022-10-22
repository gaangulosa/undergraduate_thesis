function [xp,yp]=preprocessing(x,y,method,numblocks)

%Normalization
switch method 
    case 'auto'%Autoscaling
        % [] is a special case for std and mean, just handle it out here.
        if isequal(x,[]), xp = []; return; end
 
        % Figure out which dimension sum will work along.
        sx = size(x);
        dimx = find(sx ~= 1, 1);
        if isempty(dimx), dimx = 1; end
        
        sy = size(y);
        dimy = find(sy ~= 1, 1);
        if isempty(dimy), dimy = 1; end
 
        % Need to tile the output of mean and std to standardize X and Y
        tilex = ones(1,ndims(x)); tilex(dimx) = sx(dimx);
        tiley = ones(1,ndims(y)); tiley(dimy) = sy(dimy);
%         [m_x,~] = size(x);
%         [m_y,~] = size(y);
        
        % Compute X's mean and sd, and standardize it.
        warn = warning('off','MATLAB:divideByZero');
        xbar = repmat(mean(x), tilex);
%         xbar = repmat(mean(x), 1,m_x);
        ybar = repmat(mean(x), tiley); 
%         ybar = repmat(mean(x), 1,m_y);
        sdx = repmat(std(x), tilex);
%         sdx = repmat(std(x), 1,m_x);
        sdy = repmat(std(x), tiley);
%         sdy = repmat(std(x), 1,m_y);
        warning(warn)
        sdx(sdx==0) = 1; % don't try to scale constant columns
        sdy(sdy==0) = 1; % don't try to scale constant columns
        xp = (x - xbar) ./ sdx;
        yp = (y - ybar) ./ sdy;
        
    case 'grps'%Groupscaling
        [m,n]    = size(x);
        gx       = zeros(m,n);
        n        = n/numblocks;
        %n = round(n);
        %This doesn't work for any prin comp number
        if (n-round(n))~=0
            error('"size(xin,2)/numblocks" is not an integer number.')
        end
 
        for i=1:numblocks
            j      = (i-1)*n+1:i*n;
            xin=x(:,j);
            yin=y(:,j);
            [m_x,~] = size(xin);
            [m_y,~] = size(yin);
            mx    = mean(xin);
            stdx  = std(xin);
            stdt  = sqrt(sum(stdx.^2));
            gx    = (xin-mx(ones(m_x,1),:))/stdt;
            gy    = (yin-mx(ones(m_y,1),:))/stdt;            
            xp(:,j)=gx;
            yp(:,j)=gy;
        end 
        
    case 'relat1'%Relative scale 1
        %xbar = max(max(x));
        xbar = max(x(:));
        %ybar = max(max(y));
        ybar = max(y(:));
        xp = x ./ xbar;
        yp = y ./ ybar;
        
    case 'relat2'%Relative scale 2
        [m_x,~] = size(x);
        [m_y,~] = size(y);
        xbar = repmat(max(x),m_x,1);
        ybar = repmat(max(y),m_y,1);
        xp = x ./ xbar;
        yp = y ./ ybar;
        
    case 'relat4'%Relative scale 4
        [m_x,n_x] = size(x);
        [m_y,n_y] = size(y);
        %xp = zeros(m,n);
        M = zeros(m_x,1);
        N = zeros(m_y,1);
        
        for i = 1:m_x
            X = x(i,:);
            M(i,1) = norm(X);            
        end
        for j = 1:m_y
            Y = y(j,:);
            N(j,1) = norm(Y);
        end
        Mbar = repmat(M,1,n_x);
        Nbar = repmat(N,1,n_y);
        xp = x ./ Mbar;
        yp = y ./ Nbar;
        
    case 'range1'%Range scale 1
        [m_x,~] = size(x);
        [m_y,~] = size(y);
        xbar = repmat(max(x),m_x,1);
        ybar = repmat(max(y),m_y,1);
        xbar2 = repmat(min(x),m_x,1);
        ybar2 = repmat(min(y),m_y,1);
        xp = (x - xbar2) ./ (xbar - xbar2);
        yp = (y - ybar2) ./ (ybar - ybar2);
        
    case 'range2'%Range scale 2
        [m_x,~] = size(x);
        [m_y,~] = size(y);
        xbar = repmat(max(x),m_x,1);
        ybar = repmat(max(y),m_y,1);
        xbar2 = repmat(min(x),m_x,1);
        ybar2 = repmat(min(y),m_y,1);
        xp = (2*(x - xbar2) ./ (xbar - xbar2))-1;
        yp = (2*(y - ybar2) ./ (ybar - ybar2))-1;
        
    case 'base'  %Baseline subtraction
        
    case 'snvt' %Standard normal variate transform
        xbar = mean2(x);
        ybar = mean2(y);
        xbar2 = std2(x);
        ybar2 = std2(y);
        xp = (x - xbar) ./ xbar2;
        yp = (y - ybar) ./ ybar2;
end

