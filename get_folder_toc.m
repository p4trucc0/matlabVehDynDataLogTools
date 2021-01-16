function t_out = get_folder_toc(folder_in)

dir_mat = dir([folder_in, filesep, '*.mat']);
for ii = 1:length(dir_mat)
    load([dir_mat(ii).folder, filesep, dir_mat(ii).name]);
    s_this = Test.info;
    s_this.MatFileName = dir_mat(ii).name;
    if ii == 1
        s_out = s_this;
    else
        s_out = [s_out; s_this];
    end
    clear Test
end

s_s = scalarize_struct(s_out);
t_out = struct2table(s_s);