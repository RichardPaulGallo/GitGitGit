clear all
%close all
Fs = 7.2e8;

Acryl_Signal_Low = 28.52;
Acryl_Signal_High = 30.61;

time = [1/7.2:1/7.2:511/7.2];

time_interp = 0:1/720:time(511);

frequency = Fs*(0:49999)/100000;
frequency_neg = -1*Fs*(49999:-1:0)/100000;
frequency_tot = [frequency frequency_neg];

%Signal = zeros(length(Xdinterp),10);
figure
for k=5:20
    file_name = 'capture';
    it = sprintf('%d',k);
    file_name = strcat(file_name,it);
    file_name = strcat(file_name,'.json');
    X(k) = importdata(file_name);
    Xs(k,:) = split(X(k));
    Xd(k,:) = str2double(Xs(k,12:522));
    Xdinterp(k,:) = interp1(time,Xd(k,:),[0:1/720:time(511)]);
    
    kf = 0;
    
    for j=1:length(Xdinterp(k,:))-1
        if(Xdinterp(k,j)>0 && Xdinterp(k,j+1)<0)
            kf = kf + 1;
            Zero_Cross(k,kf) = time_interp(j);
            Val_Sig(k,kf) = Xdinterp(k,j);
        elseif (Xdinterp(k,j)<0 && Xdinterp(k,j+1)>0)
            kf = kf + 1;
            Zero_Cross(k,kf) = time_interp(j);
            Val_Sig(k,kf) = Xdinterp(k,j);
        end
    end
    
    for z= 1:length(Xdinterp(k,:))
        Xd_dif(k,z) = Xdinterp(k,z) - Xdinterp(5,z);
    end
    
    for l=1:length(Xdinterp)
        if time_interp(l)>28 && time_interp(l)<31
            Signal(k,l) = Xdinterp(k,l);
        else
            Signal(k,l) = 0;
        end
    end
    
    FFT(k,:) = fft(Signal(k,:),100000);
    FFT(k,:) = abs(FFT(k,:));
    
    [FFT_Max(k),Max_freq(k)] = findMax(FFT(k,:),frequency_tot);
    FFT(k,:) = FFT(k,:);
    temp1 = Xs{k,2}(2:6);
    temp2 = Xs{k,3}(1:5);
    temp1 = strcat('Primary: ',temp1);
    temp2 = strcat('Secondary: ',temp2);
    
    
    %figure
    hold on
    if k<=12
        subplot(2,4,k-4)
    elseif k>=13
        if k == 13
            figure
        end
        subplot(2,4,k-12)
    end
    hold on
    plot(frequency_tot/1000,FFT(k,:),'-')
    grid on
    plot(0,0,'.')
    xlim([-3.4e3 3.4e3])
    ylim([0 45])
    xlabel('Frequency (kHz)')
    ylabel('Amplitude')
    cap_num = k-4;
    text = sprintf('Capture Number: %d',cap_num);
    title(text)
    legend(temp1, temp2,'Location','southoutside')
    
end

figure

for k=5:20
    temp1 = Xs{k,2}(2:6);
    temp2 = Xs{k,3}(1:5);
    if k<=12
        subplot(2,4,k-4)
    elseif k>=13
        if k==13
            figure
        end
        subplot(2,4,k-12)
    end
    hold on
    plot(frequency_tot/1000,FFT(k,:)-FFT(5,:),'-')
    plot(0,0,'.')
    grid on
    xlim([-3.4e3 3.4e3])
    ylim([-20 10])
    xlabel('Frequency (kHz)')
    ylabel('Amplitude')
    cap_num = k-4;
    texter = sprintf('Capture Number: %d',cap_num);
    title(texter)
    legend(temp1, temp2,'Location','southoutside')
end

figure

for k=5:20
    if k<=12
        subplot(2,4,k-4)
    elseif k>=13
        if k==13
            figure
        end
        subplot(2,4,k-12)
    end
    temp1 = Xs{k,2}(2:6);
    temp2 = Xs{k,3}(1:5);
    
    TemperaturePri(k) = str2double(temp1);
    TemperatureSec(k) = str2double(temp2);
    
    temp = strcat('Secondary: ',temp2);
    temper = strcat('Primary: ',temp1);
    hold on
    plot(time_interp,Xdinterp(k,:),'-')
    plot(Zero_Cross(k,:),Val_Sig(k,:),'.')
    grid on
    xlim([0 40])
    xlabel('Time (\mus)')
    ylabel('Amplitude')
    
    [Max1(k),Maxtime(k)] = findMaxTime(Signal(k,:),time_interp);
    
    cap_num = k-4;
    text = sprintf('Capture Number: %d',cap_num);
    title(text)
    legend(temper,temp,'Location','southoutside')
end

figure
for k=5:20
    if k<=12
        subplot(2,4,k-4)
    elseif k>=13
        if k==13
            figure
        end
        subplot(2,4,k-12)
    end
  
    temp1 = Xs{k,2}(2:6);
    temp2 = Xs{k,3}(1:5);
    
    TemperaturePri(k) = str2double(temp1);
    TemperatureSec(k) = str2double(temp2);
    
    temp = strcat('Secondary: ',temp2);
    temper = strcat('Primary: ',temp1);
    hold on
    plot(time_interp,Xd_dif(k,:),'-')
    plot(0,0,'.')
    grid on
    %plot(Zero_Cross(k,:),Val_Sig(k,:),'.')
    xlim([0 40])
    ylim([-.5 .5])
    xlabel('Time (\mus)')
    ylabel('Amplitude')
    
    %[Max1(k),Maxtime(k)] = findMaxTime(Signal(k,:),time_interp);
    
    cap_num = k-4;
    text = sprintf('Capture Number: %d',cap_num);
    title(text)
    legend(temper,temp,'Location','southoutside')
end

figure
time_Heat = [0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150];
plot(time_Heat,Maxtime(5:20)*1000,'-*')
xlabel('Time of Heat (sec)')
ylabel('ToF in ns')
title('ToF versus Time of Heat')

figure
hold on
plot(time_Heat,TemperaturePri(5:20),'-*')
plot(time_Heat,TemperatureSec(5:20),'-*')
xlabel('Time of Heat (sec)')
ylabel('Temperature (Celsius)')
title('Temperature versus Time of Heat')
legend('Top Sensor','Bottom Sensor','Location','southoutside')

figure
plot(TemperaturePri(5:20),Maxtime(5:20)*1000,'-*')
xlabel('Top Temperature (Celsius)')
ylabel('ToF in ns')
title('ToF versus Top Temperature')

figure
plot(TemperatureSec(5:20),Maxtime(5:20)*1000,'-*')
xlabel('Bottom Temperature (Celsius)')
ylabel('ToF in ns')
title('ToF versus Bottom Temperature')

WriteToText(Maxtime, Max_freq,Max1,FFT_Max,TemperatureSec,TemperaturePri);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[Max,Max_freq] = findMax(FFT,frequency_tot)
Max = 0;
for k=1:length(FFT)
    if FFT(k) > Max
        Max = FFT(k);
        Max_freq = frequency_tot(k);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Max,Max_time] = findMaxTime(Signal,time_interp)

Max = 0;
for k=1:length(Signal)
    if Signal(k) > Max
        Max = Signal(k);
        Max_time = time_interp(k);
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function WriteToText(Maxtime, Max_freq,Max1,FFT_Max,TemperatureSec,TemperaturePri)

fid1 = fopen('Max_Time.txt','w');
fid2 = fopen('Max_Frequency.txt','w');

for k = 5:20
    
    Seconds = 10*(k-5);
    text_time = sprintf('Max Amplitude Time at %d Seconds of Heat: %2.3f microseconds \n' ...
        ,Seconds,Maxtime(k));
    MaxAmp = sprintf('Max Amplitude at %d Seconds of Heat: %0.3f \n',Seconds,Max1(k));
    text_freq = sprintf('Max Amplitude Frequency at %d Seconds of Heat: %3.2f kHz \n'...
        ,Seconds,Max_freq(k)/1000);
    MaxFFT = sprintf('Max Amplitude at %d Seconds of Heat: %2.3f \n',Seconds,FFT_Max(k));
    TempSec = sprintf('Bottom Temperature at %d Seconds of Heat: %2.2f Celsius\n',Seconds,TemperatureSec(k));
    TempPri = sprintf('TopTemperature at %d Seconds of Heat: %2.2f Celsius\n\n',Seconds,TemperaturePri(k));
    fwrite(fid1,text_time);
    fwrite(fid1,MaxAmp);
    fwrite(fid1,TempSec);
    fwrite(fid1,TempPri);
    fwrite(fid2,text_freq);
    fwrite(fid2,MaxFFT);
    fwrite(fid2,TempSec);
    fwrite(fid2,TempPri);
end

fclose(fid1);
fclose(fid2);
    

end  