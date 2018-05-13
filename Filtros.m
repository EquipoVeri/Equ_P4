%% Filtros
%  Diego Eduardo Reyna Cruz
%  Felipe de Jesús Garcia Soto
%
%  ITESO - 10/05/18
%  Diseno y Verificacion de Sistemas Digitales
%
%  Practica 4 - Ecualizador de tres bandas
%% 1 - Diseno de Filtros FIR con MATLAB:

% Limpiando workspace, command window y poniendo formato en long:
clear all
format long
clc

% Lectura de un archivo de la carpeta local de MATLAB (para pruebas):
[x,Fs] = audioread('spring_HiFi.wav');

% -----------------------------------------------------------------------

% Se calcula la transformada de Fourier de x(n):
x_fft = fft(x)';
% Magnitud de transformada:
x_fft_abs = abs(x_fft);

% Creando un eje horizontal tomando en cuenta la frecuencia de muestreo de
% la senal de audio. El eje llega hasta ws/2, porque se sabe que en matlab
% fft() va desde 0 hasta ws, replicando el espectro despues de ws/2, por lo
% que solo es este valido hasta ws/2. ws = 2*pi*Fs. Se debe tener la mitad
% de puntos que la fft() completa para llegar hasta ws/2:
w_n = linspace(0,Fs/2,length(x)/2);

% Grafica de X(w):
figure,
plot(w_n,x_fft_abs(1,1:length(x)/2));
axis([0 Fs/2 0 inf])
grid on
title('TF de x(n)')
ylabel('Magnitud de X(\omega)')
xlabel('F [Hz]')

% -----------------------------------------------------------------------

% Frecuencias de corte:
f_corte_LPF = 800; 
f_corte_BPF_1 = 1000;
f_corte_BPF_2 = 3000;
f_corte_HPF   = 3500;

% Seleccionando orden del filtro (para 32 coeficientes):
n_order_LPF = 31;
n_order_BPF = 31;
n_order_HPF = 30;

% Creando filtro pasabajas de orden 31:
LPF_N_31 = fir1(n_order_LPF,f_corte_LPF/(Fs/2),'low',hamming(n_order_LPF + 1));

% Creando filtro pasabandas de orden 31:
BPF_N_31 = fir1(n_order_BPF,[f_corte_BPF_1/(Fs/2),f_corte_BPF_2/(Fs/2)],'bandpass',hamming(n_order_BPF + 1));

% Creando filtro pasaaltas de orden 31:
HPF_N_30 = fir1(n_order_HPF,f_corte_HPF/(Fs/2),'high',hamming(n_order_HPF + 1));
HPF_N_31 = [HPF_N_30,0];

% Graficando respuesta en frecuencia de filtros:
A = fvtool(LPF_N_31,1,BPF_N_31,1,HPF_N_31,1);

% -----------------------------------------------------------------------

% Se aplican los filtros a la senal de audio de entrada:
y_LPF_N_31 = filter(LPF_N_31,1,x);
y_BPF_N_31 = filter(BPF_N_31,1,x);
y_HPF_N_31 = filter(HPF_N_31,1,x);

% Calculando fft() para cada senal filtrada:
y_LPF_N_31_fft = abs(fft(y_LPF_N_31))';
y_BPF_N_31_fft = abs(fft(y_BPF_N_31))';
y_HPF_N_31_fft = abs(fft(y_HPF_N_31))';

% Graficando espectros de frecuencias de senales de entrada filtradas.
% 
% Grafica de FIR-LPF:
figure,
plot(w_n,y_LPF_N_31_fft(1,1:length(x)/2),'r');
axis([0 Fs/2 0 inf])
grid on
lgs = {'n = 31'};
legend(lgs)
title('TF de y(n) con Filtro PasaBajas FIR1 con f_c = 800 Hz')
ylabel('Magnitudes de Y(\omega)')
xlabel('F [Hz]')

% Grafica de FIR-BPF:
figure,
plot(w_n,y_BPF_N_31_fft(1,1:length(x)/2),'r');
axis([0 Fs/2 0 inf])
grid on
lgs = {'n = 31'};
legend(lgs)
title('TF de y(n) con Filtro PasaBandas FIR1 con f_c_1 = 1K Hz, f_c_2 = 3K Hz')
ylabel('Magnitudes de Y(\omega)')
xlabel('F [Hz]')

% Grafica de FIR-HPF:
figure,
plot(w_n,y_HPF_N_31_fft(1,1:length(x)/2),'r');
axis([0 Fs/2 0 inf])
grid on
lgs = {'n = 31'};
legend(lgs)
title('TF de y(n) con Filtro PasaAltas FIR1 con f_c = 3.5K Hz')
ylabel('Magnitudes de Y(\omega)')
xlabel('F [Hz]')

% -----------------------------------------------------------------------

% Creacion de objetos tipo 'audioplayer' para reproduccion de resultados:
x_sound = audioplayer(x,Fs);
x_sound_y_LPF_N_31 = audioplayer(y_LPF_N_31,Fs);
x_sound_y_BPF_N_31 = audioplayer(y_BPF_N_31,Fs);
x_sound_y_HPF_N_31 = audioplayer(y_HPF_N_31,Fs);

% Reproduccion de las senales de audio:

disp(' ');
disp('Reproduciendo audio original');
play(x_sound);
disp('Presione cualquier tecla para siguiente audio');
disp(' ');
pause

disp(' ');
disp('Reproduciendo audio resultante de FIR1-LPF con n = 31 y fc = 800 Hz');
play(x_sound_y_LPF_N_31);
disp('Presione cualquier tecla para siguiente audio');
disp(' ');
pause

disp(' ');
disp('Reproduciendo audio resultante de FIR1-BPF con n = 31 y fc1 = 1K Hz, fc2 = 3K Hz');
play(x_sound_y_BPF_N_31);
disp('Presione cualquier tecla para siguiente audio');
disp(' ');

pause
disp(' ');
disp('Reproduciendo audio resultante de FIR1-HPF con n = 31 y fc = 3.5K Hz');
play(x_sound_y_HPF_N_31);
disp('Presione cualquier tecla para mostrar coeficientes en binario de punto fijo');
disp(' ');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 2 - Coeficientes de filtros en binario de punto fijo
% Generador de datos

% Indicando que los datos son signados.
Signed = 1;
% Ancho de 16 bits por coeficiente.
Word_Length = 16;
% Dos bits de parte entera.
Integer_Part = 2;
% 14 bits de parte fraccional.
Fractional_Part = Word_Length - Integer_Part;
% Indicando formato de punto fijo.
Data_Format = numerictype('Signed',Signed,'WordLength',...
                          Word_Length,'FractionLength',Fractional_Part);
% Indicando formato de punto fijo.
Data_OP = fimath('RoundMode','floor','OverflowMode','wrap',...
            'ProductMode','SpecifyPrecision',...
           'ProductWordLength',Word_Length,...
           'ProductFractionLength',Fractional_Part,...
           'SumMode','SpecifyPrecision',...
           'SumWordLength',Word_Length,...
           'SumFractionLength',Fractional_Part); 
       
% -----------------------------------------------------------------------
% Golden Model

disp('************************************')
disp('************************************')
disp('  ')
disp('Valores de punto flotante')
disp('  ')
disp('Filtro PasaBajas')
disp('  ')
disp(LPF_N_31)
disp('  ')
disp('  ')
disp('Filtro PasaBandas')
disp('  ')
disp(BPF_N_31)
disp('  ')
disp('  ')
disp('Filtro PasaAltas')
disp('  ')
disp(HPF_N_31)
disp('  ')
disp('************************************')
disp('************************************')
disp('  ')
disp('  ')

% -----------------------------------------------------------------------
% Reference Model

LPF_N_31_FP = fi(LPF_N_31,Data_Format, Data_OP);
BPF_N_31_FP = fi(BPF_N_31,Data_Format, Data_OP);
HPF_N_31_FP = fi(HPF_N_31,Data_Format, Data_OP);

disp('************************************')
disp('************************************')
disp('  ')
disp('Valores de punto fijo')
disp('  ')
disp('Filtro PasaBajas')
disp('  ')
disp(LPF_N_31_FP.double)
disp(LPF_N_31_FP.bin)
disp(LPF_N_31_FP.hex)
disp('  ')
disp('  ')
disp('Filtro PasaBandas')
disp('  ')
disp(BPF_N_31_FP.double)
disp(BPF_N_31_FP.bin)
disp(BPF_N_31_FP.hex)
disp('  ')
disp('  ')
disp('Filtro PasaAltas')
disp('  ')
disp(HPF_N_31_FP.double)
disp(HPF_N_31_FP.bin)
disp(HPF_N_31_FP.hex)
disp('  ')
disp('************************************')
disp('************************************')
disp('  ')
disp('  ')

% -----------------------------------------------------------------------
% Creando archivos .txt para las memorias ROM.

% Filtro PasaBajas
LPF_ID = fopen('LPF.txt','w');
for i = 1:length(LPF_N_31_FP)
    fprintf(LPF_ID,'%s\n',hex(LPF_N_31_FP(i)));
end
fclose(LPF_ID);

% Filtro PasaBandas
BPF_ID = fopen('BPF.txt','w');
for i = 1:length(BPF_N_31_FP)
    fprintf(BPF_ID,'%s\n',hex(BPF_N_31_FP(i)));
end
fclose(BPF_ID);

% Filtro PasaAltas
HPF_ID = fopen('HPF.txt','w');
for i = 1:length(HPF_N_31_FP)
    fprintf(HPF_ID,'%s\n',hex(HPF_N_31_FP(i)));
end
fclose(HPF_ID);
       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
