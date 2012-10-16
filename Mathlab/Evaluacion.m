%% Inicializamos WorkSpace
clear

%% Leemos todos los ficheros de resultados
path = '/opt/bioid/test/res/';
res_files = dir([path '*[0-9].res']);

u = 0;
s = 0;
telefono = '';
for i = 1 : numel(res_files)
	if (res_files(i).bytes > 0) % Comprobamos si hay datos
		[Gender ID OK name Scores] = textread([path res_files(i).name],'%s %s %d %s %f');
		%if ~isempty(Scores) 
        % comprobamos si es un usuario nuevo
        if strcmp(telefono,char(ID(1)))
            % Si no es un nuevo usuario, incrementamos indice de muestra
            % (sample)
            s = s + 1;
        else
            % Si es nuevo...
            telefono = char(ID(1)); % guardamos valor ID
            u = u + 1;              % Incrementamos indice usuario
            s = 1;                  % Reseteamos valor 
        end
        % Eliminamos la primera l�nea (el usuario esta repetido)
        ID(1) = [];
        Scores(1) = [];
        % Guardamos valores en la estructura users
        users(u).sample(s).scores = Scores;
        users(u).sample(s).ID = ID;
    end
end

%% Obtenemos scores genuinos
% Inicializamos variables
scores_gen = [];
scores_falsas = [];
% Para las muestras genuinas
for u = 1 : numel(users) % Para todos los usuarios
    for s = 1 : numel(users(u).sample)     % Para todas las muestras de cada usuario
        %% Para las comparaciones genuinas
        % obtenemos la comparaci�n de la muestra con el patr�n genuino
        scores = users(u).sample(s).scores;
        % Lo guardamos en el array de Scores Genuinos: Col1 User, Col2->
        % Muestra, Col3 -> Valor de comparaci�n
        scores_gen(end+1,1) = u;            % Col 1 -> Usuario ID
        scores_gen(end,2) = s;              % Col 2 -> Muestra ID
        scores_gen(end,3) = scores(u);      % Col 3 -> Valor Comparaci�n
    
    
        %% Para las comparaciones falsas
        for ou = 1 : numel(scores)
            if (ou~=u) % para las comparaciones de esta muestra con los patrones de otros usuarios
                scores_falsas(end+1,1) = u;             % col 1 -> Usuario al que pertenece la muestra
                scores_falsas(end,2) = ou;              % col 2 -> Patr�n contra el que se compara la muestra (otro usuario)
                scores_falsas(end,3) = s;               % col 3 -> Muestra ID
                scores_falsas(end,4) = scores(ou);      % col 4 -> Valor de comparaci�n
            end
        end
    end
end

%% Par�metros de Evaluaci�n (Gr�ficas FAR-FRR, ROC, EER, Operating Point)
% Calculamos e imprimimos evaluaci�n de VERIFICACI�N
[EER confInterEER OP confInterOP] = EER_DET_conf(scores_gen(:,end),scores_falsas(:,end),1,100,0);
%% Gr�fica de IDENTIFICACI�N CMC
plot_CMC(scores_gen,scores_falsas,10);
%% Mostramos en Pantalla EER
disp(num2str(EER));
%% Gr�fica de Distribuci�n de Scores (Genuinios y Falsos)
plot_dist(scores_gen(:,end),scores_falsas(:,end),100);

