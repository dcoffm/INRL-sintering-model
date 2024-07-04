classdef ImportExport < handle_light
methods 
        
    function this = ImportParams(this,fname,fields)
        % Takes the name of a *.m file and reads selected fields into the class fields
        % If "fields" is not provided, it assumes all
        
        a = load(fname);
        if nargin==2
            fields = fieldnames(a);
        end
        
        for i = 1:numel(fields)
            try
                this.(fields{i}) = a.(fields{i});
            catch
                warning('Failed to import field: %s',fields{i})
            end
        end
    end

    function this = ExportParams(this,fname,classList)
        % If classes == 0 -> only fields from this class
        % If classes  > 0 -> all fields
        % If classes is a cell array, only fields from classes in the list
        
        if nargin==2
            classList = 0;
        end
        
        mc = metaclass(this);
        
        for i = 1:numel(mc.PropertyList)
            name = mc.PropertyList(i).Name;
            from = mc.PropertyList(i).DefiningClass.Name;
            if ~isa(classList,'cell')
                if classList ==0
                    if strcmp(from,mc.Name)
                        a.(name) = this.(name); 
                    end
                else % Argument was "all" 
                    a.(name) = this.(name); 
                end
                
            else % Check if it's in the list requested
                for j = 1:numel(classList)
                    if strcmp(from,classList{j})
                        a.(name) = this.(name);
                    end
                end
            end
        end
        save(fname,'-struct','a')
        
    end
end
end