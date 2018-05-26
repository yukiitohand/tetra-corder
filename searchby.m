function [ res,resIdx ] = searchby( field,vals,arOfstruct, varargin )
% [ res,resIdx ] = searchby( field,val,arOfstruct )
%   search instances in the speclib or references of Tetracorder with their
%   field.
% Inputs:
%   field: field to be searched, string, 
%          currently, 'irecno', 'g_id', 'outputbase', 'name', and 'ititl' 
%          are supported
%   vals:  val to be compared, if the field is 'irecno' or 'g_id', val has 
%          to be a scalar or array of scalars. 
%          If 'outputbase', 'name', or 'ititl', any regular expression or 
%          cell array of it is accepted
%  Optional variables
%  'COMP_FUNC': 'regexp' (default) or 'strcmp' is supported if you choose
%  'outputbase', 'name', or 'ititl' as a field. Otherwise, it will be just
%  ignored.
% Outputs:
%   res: arOfStruct that matches
%   resIdx: corresponding indices


comp_func = 'regexpi';

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'COMP_FUNC'
                comp_func = varargin{i+1};
            otherwise
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end



resIdx = false(1,length(arOfstruct));


if ~isfield(arOfstruct,field)
    error(sprintf('There is no field %s\n',field));
end

if strcmp(field,'irecno') || strcmp(field,'g_id')
    for iv=1:length(vals)
        val = vals(iv);
        resIdxtmp = [arOfstruct.(field)]==val;
        resIdx = or(resIdx,resIdxtmp);
    end
else
% elseif strcmp(field,'ititl') || strcmp(field,'desc') || strcmp(field,'name') || strcmp(field,'outputbase') || strcmp(field,'group')
    if iscell(vals)
        for iv=1:length(vals)
            val = vals{iv};
            valList = [{arOfstruct.(field)}];
            for i=1:length(valList)
                if ~isempty(valList{i})
                    if strcmp(comp_func,'regexpi')
                        if isnumeric(valList{i})
                            valList{i} = num2str(valList{i});
                        end
                        if ~isempty(regexpi(valList{i},val))
                            resIdx(i) = true;
                        end
                    elseif strcmp(comp_func,'strcmp')
                        if strcmp(valList{i},val)
                            resIdx(i) = true;
                        end
                    elseif strcmp(comp_func,'strcmpi')
                        if strcmpi(valList{i},val)
                            resIdx(i) = true;
                        end
                    end
                end
            end
        end
    elseif ischar(vals)
        val = vals;
        valList = [{arOfstruct.(field)}];
        for i=1:length(valList)
            if ~isempty(valList{i})
                if strcmp(comp_func,'regexpi')
                    if isnumeric(valList{i})
                            valList{i} = num2str(valList{i});
                    end
                    if ~isempty(regexpi(valList{i},val))
                        resIdx(i) = true;
                    end
                elseif strcmp(comp_func,'strcmp')
                    if strcmp(valList{i},val)
                            resIdx(i) = true;
                    end
                elseif strcmp(comp_func,'strcmpi')
                    if strcmpi(valList{i},val)
                        resIdx(i) = true;
                    end
                end
            end
        end
    end
end
resIdx = find(resIdx);
res = arOfstruct(resIdx);

end

