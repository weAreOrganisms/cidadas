// TODO: run analysis engines to be picked up by vowel synths
var all;

(
all = 5.collect{|index|
	var name = "fft%".format(index).asSymbol;

	m.gens[name].isNil.if{
		"init %".format(name).postln;
	};
	m.gens[name] = Ndef(name);

	Ndef(name).ar(2);
	Ndef(name).addSpec(
		\tlFreq, \freq,
		\lowcutFreq, \freq,
		\highcutFreq, \freq,
		\thFreq, \freq,
		\postAmp, [0, 20],
		\on, [0, 1, \lin, 1], // on/off mechanism for m.selectGenerator
		// \in, [0, 100, \lin, 1] // feeding buffer
	);

	Ndef(name, {
		var lowcutFreq = \lowcutFreq.kr(5400).varlag(1);
		var highcutFreq = \highcutFreq.kr(15500).varlag(1);
		var tlFreq = \tlFreq.kr(50).varlag(1);
		var thFreq = \thFreq.kr(5000).varlag(1);


		var snd;
		var hpFactor = lowcutFreq / (SampleRate.ir * 0.5); // high-pass (plus)
		var lpFactor = (1-(highcutFreq / (SampleRate.ir * 0.5))).neg; // low-pass (minus)
		var in, chain, flux, fluxPos;
		var buf = LocalBuf(m.config.windowSize, 1);




		var stretch = (thFreq - tlFreq)/ (highcutFreq - lowcutFreq);
		var shift = ((stretch * lowcutFreq) - tlFreq).neg  / (SampleRate.ir/m.config.windowSize);

		in = \in.ar(0);// * on;
		chain = FFT(buf, in);
		chain = PV_BrickWall(chain, hpFactor);
		chain = PV_BrickWall(chain, lpFactor);

		flux = FFTFlux.kr(chain, 0.9);
		// fluxPos = FFTFluxPos.kr(chain, 0.9);


		chain = PV_BinShift(chain, stretch, shift);


		// measurements
		// Out.kr(10 + (2*i), [flux, fluxPos]);

		snd = (IFFT(chain) * \postAmp.kr(1)).tanh;

		Pan2.ar(snd, LFNoise1.kr(Rand(0.05 + flux.linlin(0, 1, -1, 1))));
	}).play;
}
);


////////////// MAPPING ///////////////////////
// Ndef(\fft).addHalo(\offFunc, {
// 	Ndef(\fft).set(\on, 0);
// 	// Ndef(\fft).stop;
// });
//
// Ndef(\fft).addHalo(\onFunc, {
// 	Ndef(\fft).set(\on, 1);
// 	// Ndef(\fft).play;
// });


/////// additional mapping (to your controllers) ///////////


////// assign functions to keyplayer

// Ndef(\fft).addHalo(\kpAction_a, {
// 	"%: a pressed.".format(\fft).inform;
// });

/////////// ALWAYS RETURN Ndef //////////////

all.first; // return value


//////////////// TESTS /////////////

/*

m.ctls.pp.capNormVals
m.ctls.pp.imuDict
m.ctls.pp.encoderDict

*/