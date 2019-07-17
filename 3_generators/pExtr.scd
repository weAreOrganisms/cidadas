var all;

all = m.samples.cMono.collect{|buffer, bName|
	var name = "p%".format(bName.asString[1..]).asSymbol;

	m.gens[name].isNil.if{
		"init %".format(name).postln;
	};
	m.gens[name] = Ndef(name);
	Ndef(name).ar(2);

	Ndef(name).addSpec(
		\rate, [1/16, 1, \exp],
		\delta, [1/32, 64, \exp],
		// \tonal, [0,2],
		\rootFreq, [20, 1000, \exp],
		// \thresh, [0, 1],
		\fbScale, [1, 10],
		\pitchVarScale, [1, 10],
		\analysisFreq, [1000, 22000, \exp],

		\ampContrast, [1, 4],
		\noiseAmp, [0, 10],
		\synthAmp, [0, 10],
		\bandAmp, [0, 10],
		\postAmp, [0, 20],
	);

	Ndef(name, {
		// player vars
		var
		delta, mode, isRepeat,
		bufnum, rate, numFrames,
		trigRepeat, loopStart,
		phase, bufdur, trigger, bSR;


		// pattern vars
		var snd, bands, analysisAmps, analysisGates, pitchVars, playFreqs, analysisFreqs, postAmp, tonal, rootFreq, thresh, bandRq, fbs, fbScale, pitchVarScale, ampContrast, noiseAmp, synthAmp, bandAmp;



		delta   = \delta.kr(1);
		// bufnum  = \bufnum.kr(0);
		bufnum = buffer.bufnum;
		trigger = \trigger.tr(0);
		bufdur  = BufDur.kr(bufnum);
		rate    = BufRateScale.kr(bufnum) * \rate.kr(1);
		bSR     = BufSampleRate.kr(bufnum);
		numFrames = min(BufFrames.kr(bufnum), m.config.maxFrame);

		// trig controls
		mode = ToggleFF.ar(Trig.ar(trigger));
		isRepeat = Trig.ar(mode);

		// in secs:

		trigRepeat = TDuty.ar(Dseq([delta], inf), isRepeat, gapFirst: 1);
		// play everything until button pressed
		trigRepeat = Select.ar(mode, [Silent.ar, trigRepeat]);

		loopStart = Latch.ar(LocalIn.ar(1) - delta, isRepeat) % bufdur;

		// in frames
		phase = Phasor.ar(
			trigRepeat, rate,
			0, numFrames,
			resetPos: loopStart * bSR
		) % numFrames;

		// feed current position back to be used to determine loop start on trigger
		LocalOut.ar(phase / bSR);

		snd = BufRd.ar(1, bufnum, phase, 1, 2);

		/////////////////// pattern //////////////////////////////


		tonal = \tonal.kr(0, 0.1);
		postAmp = \postAmp.kr(0, 0.1);

		// TODO: spreading of analysis freqs?
		analysisFreqs = \analysisFreq.kr(1000) * [0.95, 1, 0.9] * rate;
		rootFreq = \rootFreq.kr(50, 0.1);
		bandRq = 0.001;
		// thresh = \thresh.kr(0, 0.1) * bandRq * 5;
		fbScale = \fbScale.kr(1, 0.1);
		// pitchVarScale = \pitchVarScale.kr(1, 0.1);
		noiseAmp = \noiseAmp.kr(0).varlag(0.2);
		synthAmp = \synthAmp.kr(0).varlag(0.2);
		bandAmp = \bandAmp.kr(0).varlag(0.2);

		ampContrast = \ampContrast.kr(1);

		playFreqs = rootFreq * [1.5, 1, 1.7];
		postAmp = postAmp * AmpComp.kr(playFreqs);


		bands = analysisFreqs.collect{|freq|
			BPF.ar(snd, freq, bandRq)
		};

		analysisAmps = Amplitude.ar(bands, 0.01, 0.01);
		// analysisGates = analysisAmps >= thresh; // either 0 or 1
		pitchVars = ZeroCrossing.ar(bands) * analysisFreqs.reciprocal;
		fbs = analysisAmps.linlin(0, 1, 0.5, 2);
		// pitchVars.poll;

		// amplitude contrast: quite quiter, loud louder
		analysisAmps = (analysisAmps * 7 * ampContrast).min(1) ** (ampContrast);


		snd = Mix([
			noiseAmp * BPF.ar(PinkNoise.ar(analysisAmps * postAmp * 100), playFreqs * VarLag.ar(pitchVars, 0.01, start: 1)),
			synthAmp * analysisAmps * postAmp * SinOscFB.ar(playFreqs * pitchVars, (fbs.neg * fbScale).min(2)),
			bandAmp * PitchShift.ar(bands, 0.12, pitchRatio: rate.reciprocal, timeDispersion: 0.000) * postAmp
		]);

		// snd = snd;

		Splay.ar(snd, 0.3).tanh;


	}).play;

	Ndef(name); // return value
};

all; // return value
