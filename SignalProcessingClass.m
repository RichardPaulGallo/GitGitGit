classdef SignalProcessingClass
    %{
    The SignalProcessClass allows a user to input a time signal into the
    class. The class then interpolates the time signal by 100 (spline
    interpolation), performs an FFT on the signal, and can perform a
    Bandpass, Lowpass, Highpass, or StopBand Filter on the time signal.
    %}
    properties (Access = public)
        %{
        properties have public access. They include low cutoff frequency
        (fL) high cutoff frequency (fH), FilterType, endIndex of signal to
        average raw data, Signal, Sampling frequency, frequency domain,
        filtered signal, FFT, bandpassed FFt, and the filter used
        %}
        fL
        fH
        FilterType
        endIndex
        Signal
        Fs
        frequency
        ProcessedSignal
        FFT
        FFTP
        filter
    end
    
    methods (Access = public)
        %{
        Methods include constructor, Bandpass --Can do both High pass and
        Low pass filtering--, StopBand, Average multiple captures of raw
        data, interpolate time signal, obtain frequency domain vector,
        create a new interpolated and filtered signal object, and plot
        filter, Frequency Domain, and time domain signals.
        %}
        function self = SignalProcessingClass(fL,fH,FilterType,endIndex,Signal,Fs)
            self.fL = fL;
            self.fH = fH;
            self.FilterType = FilterType;
            self.endIndex = endIndex;
            self.Signal = Signal;
            self.Fs = Fs;
        end
        
        function[Signal_BP,FFT,FFT_bp,filter] = Bandpass(self)
            len = length(self.Signal);
            
            filter = zeros(len,1);
            frequency_dom1 = [0:self.Fs/len:self.Fs/2];
            frequency_dom2 = [-self.Fs/2:self.Fs/(len):0];
            frequency_dom = [frequency_dom1 frequency_dom2];
            
            for k=1:len
                if abs(frequency_dom(k))>=self.fL && abs(frequency_dom(k))<=self.fH
                    filter(k) = 1;
                else
                    filter(k) = 0;
                end
            end
            
            FFT = fft(self.Signal);
            for k=1:length(self.Signal)
                FFT_bp(k) = FFT(k) * filter(k);
            end
        
            Signal_BP = ifft(FFT_bp);
        end
        
        function[Signal_SB,FFT,FFT_sb,filter] = StopBand(self)
            
            len = length(self.Signal);
            
            filter = zeros(len,1);
            frequency_dom1 = [0:self.Fs/len:self.Fs/2];
            frequency_dom2 = [-self.Fs/2:self.Fs/(len):0];
            frequency_dom = [frequency_dom1 frequency_dom2];
            
            for k=1:len
                if abs(frequency_dom(k))<=self.fL || abs(frequency_dom(k))>=self.fH
                    filter(k) = 1;
                else
                    filter(k) = 0;
                end
            end
            figure
            plot(filter)
            FFT = fft(self.Signal);
            for k=1:length(self.Signal)
                FFT_sb = FFT(k) * filter(k);
            end
            
            Signal_SB = ifft(FFT_sb);
        end
        
        function [Avg] = Average(self)
            
            len = length(self.Signal);
            sum = zeros(self.endIndex,1);
            it = 0;
            for k=0:self.endIndex:len-self.endIndex
                for j = 1:self.endIndex
                    index = k+j;
                    sum(j) = sum(j) + self.Signal(index);
                end
                it = it +1;
            end
            
            Avg(:) = sum(:)/it;
            
        end
        
        function[Sig_Interp]= Interpolation(self,interp)
            time = [1/(self.Fs):1/(self.Fs):length(self.Signal)/self.Fs];
            time_interp = [0:1/(interp*self.Fs):length(self.Signal)/self.Fs];
            Sig_Interp = interp1(time,self.Signal,time_interp,'spline');
        end
        
        function[frequency] = frequency_domain(self)
            len = length(self.Signal);
            freq1 = [0:self.Fs/len:(self.Fs)/2-self.Fs/len];
            freq2 = [-self.Fs/2:self.Fs/len:self.Fs/len];
            frequency = [freq1 freq2];
            if(length(self.FFT) == 51201)
                frequency = frequency(1:51201);
            elseif(length(self.FFT) == 51200)
                frequency = frequency(1:51200);
            end
        end
            
        function[other] = RunSignalProcessClass(self)
            other = SignalProcessingClass(self.fL,self.fH,...
                self.FilterType,self.endIndex,self.Signal,self.Fs);
            other.Signal = self.Average();
            other.Signal = other.Interpolation(100);
            other.Fs = self.Fs*100;
            other.frequency = other.frequency_domain();
            if strcmp(self.FilterType,'StopBand')
                [other.ProcessedSignal, other.FFT,other.FFTP,other.filter] = other.StopBand();
            else
                [other.ProcessedSignal, other.FFT,other.FFTP,other.filter] = other.Bandpass();
            end
        end
        
        function PlotSignal(self,k)
            time = [1/self.Fs:1/self.Fs:length(self.Signal)/self.Fs];
            time2 = [1/self.Fs:1/self.Fs:(length(self.Signal))/self.Fs];
            figure
            hold on
            if(length(self.FFT) == 51201)
                self.frequency = self.frequency(1:51201);
            elseif(length(self.FFT) == 51200)
                self.frequency = self.frequency(1:51200);
            end
            %plot(time(:)*10^6,self.Signal(:),'-')
            plot(time(:)*10^6,self.ProcessedSignal,'-')
            ylim([-.5 .5])
            xlim([0 65])
            xlabel('Time (\mus)')
            ylabel('Amplitude')
            Seconds = 10*(k-5);
            text = sprintf('Reflection at %d Seconds of Heat',Seconds);
            title(text)
        end
       
        function[other] =  Amplitude(self)
            other = SignalProcessingClass(self.fL,self.fH,...
                self.FilterType,self.endIndex,self.Signal,self.Fs);
            
            Z1(:) = self.ProcessedSignal;
            Z2(:) = conj(self.ProcessedSignal);
            
            for k=1:length(Z1)
                Mag(k) = Z1(k) * Z2(k);
                if real(Z1(k))<=0
                    Mag(k) = -1*sqrt(Mag(k));
                else
                    Mag(k) = sqrt(Mag(k));
                end
                other.ProcessedSignal(k) = Mag(k);
            end
        end
    end
end