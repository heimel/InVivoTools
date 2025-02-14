function [x, active] = pool_size()
%POOL_SIZE - temporary hack to return size of current MATLABPOOL / PARPOOL
%
% see:
% http://www.mathworks.com/support/solutions/en/data/1-5UDHQP/index.html?product=DM&solution=1-5UDHQP

    %% get pool size - this should work for ALL matlab versions
    try
        
        x = 0;
        
        try % this will only work with matlab <= 2013b
            session = com.mathworks.toolbox.distcomp.pmode.SessionFactory.getCurrentSession;
            
            if ~isempty( session ) && session.isSessionRunning() && session.isPoolManagerSession()
                
                try % works with matlab >= 2009b && <= 2013b
                    x = session.getPoolSize();
                catch % works with any matlab version <= 2012b
                    client = distcomp.getInteractiveObject();
                    if strcmp( client.CurrentInteractiveType, 'matlabpool' )
                        x = session.getLabs().getNumLabs();
                    end
                end
            end
            
        catch % check for matlab == 2014a 
            poolobj = gcp('nocreate');
            if isempty(poolobj)
                x = 0;
            else
                x = poolobj.NumWorkers;
            end
        end

    catch me %#ok<NASGU>
        % standalone matlab installations might not have the appropriate
        % com module installed.
        x = 0;
    end
    

    %% is matlabpool / parpool active?
    active = return_active(x);

end

function active = return_active(x)
    active = 0;
    if x > 0
        active = 1;
    end
end
%% EOF
