m.samples.cMono.collect{|buffer, name|
	m.helpers[name] = Ndef(name);

	Ndef(name).addSpec(
		\rate, [0, 1],
		\delta, [1/32, 64, \exp]
	);

	Ndef(name, {
		var
		delta, mode, isRepeat,
		bufnum, rate, numFrames,
		trigRepeat, loopStart,
		phase, bufdur, trigger, bSR;

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

		BufRd.ar(1, bufnum, phase, 1, 2)
	});

	Ndef(name); // return value
}
