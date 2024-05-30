function BLOCKS = fun_get_index_blocks(B,N)
row1 = 1:ceil(N/B):N;
row2 = ceil(N/B):ceil(N/B):N;

if numel(row2) < numel(row1)
    row2(end+1) = N;
end
BLOCKS = [row1;row2];
if size(BLOCKS,2) ~= B
    error('The number of Blocks does not work!!!!')
end