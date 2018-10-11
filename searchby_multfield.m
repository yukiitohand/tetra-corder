function [ res,resIdx ] = searchby_multfield( fields,vals,arOfstruct, varargin )
% [ res,resIdx ] = searchby_multfield( fields,val,arOfstruct )
%   search instances in the speclib or references of Tetracorder with their
%   field.
% Inputs:
%   fields: field to be searched, string, or cell of the field names
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

if ischar(fields)
    [ res,resIdx ] = searchby( fields,vals,arOfstruct,varargin{:} );
elseif iscell(fields)
    resIdx = false(1,length(arOfstruct));
    for i=1:length(fields)
        field = fields{i};
        [ resi,resIdxi ] = searchby( field,vals,arOfstruct, varargin{:} );
        resIdx(resIdxi) = true;
    end
    res = arOfstruct(resIdx);
    resIdx = find(resIdx);
end

end
