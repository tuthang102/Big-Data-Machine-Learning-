function [vals, counts]= largest_label_volume(im,bg=-1)

[vals counts]=unique(im);
counts=counts(vals ~= bg);
vals= vals( vals~= bg);

if length(counts)>0
   vals(max(counts))
end