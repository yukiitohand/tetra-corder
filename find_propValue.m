function [value] = find_propValue(descript_html,prop_key)
% [doc_format] = find_propValue(descript_html,prop_key)
%   find the property value for a given key in a format like below.
%   Designed for reading description in USGS splib
%   
%   <p>
%     prop_key: value 
%   <p>
%
%   Inputs
%      descript_html: strings, html
%      prop_key: strings, 
%   Outputs
%      value: string, '' if no match  
% prop_key = upper(prop_key);
ptr = ['<[pP]{1}>[\s]*' prop_key ':\s*([\S]{1}[^\<\>]*[\S]{1}|[\S]{1})[\s]*<[pP]{1}>'];
value = regexpi(descript_html,ptr,'tokens');
if isempty(value)
    value = '';
else
    value = value{1}{1};
end
end