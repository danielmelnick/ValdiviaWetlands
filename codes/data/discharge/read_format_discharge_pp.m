clear

load discharge_Rucaco.mat

dis=discharge_Rucaco;
dis.yd=datetime_to_decimal_year(dis.Fecha);

save("Rucaco.mat",'dis')

%%

load pp_Pichoy.mat
