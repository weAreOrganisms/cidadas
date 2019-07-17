/********
Server.killAll;
*********/

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
(
///////////    UTILS	  ///////////////////////
m = MeTA(path: thisProcess.nowExecutingPath.dirname, server: s);

/*
m.openFiles("configs",   ["3_userConfig"], warn: true);
*/

///////////    CONFIG	  ///////////////////////
// configuration of your performance. give general information such as number of channels, server options etc.

m.config.numChans = 2;

m.loadFiles("configs", [
	"1_serverConfig",
	"2_networkConfig",
	"4_freqRanges",
	"3_userConfig",
]);




m.loadFiles("utils", [
	"1_controlUtils"
]);

// boot server and load generators

m.server.waitForBoot({
	/*
	m.server.boot;
	*/
	//	m.server.scope(q.numChans).window.bounds_(Rect(700, 5, 261, 250));

	m.loadSamples("cMono");
	// keep only those samples we want to use
	m.samples.cMono = m.samples.cMono.select{|buffer, key|
		m.config.sampleNames.includes(key)
	};


	///////////   HELPER NDEFS  ///////////////////////
	"loading HELPERS...".inform;
	m.loadFiles("helperNdefs", ["players"]);


	///////////    GENERATORS	  ///////////////////////
	"loading GENS...".inform;
	m.loadGen("pExtr" , 1);
	m.loadGen("fft" , 2);
	// m.loadGen("buzz"   , 2);
	// m.loadGen("yourGen", 3);



	// /////  play all Ndefs
	// 0.5.wait;
	// "play GENS...".inform;
	// q.utils.getNdefs.do {|ndef|
	// 	ndef.play;
	// };
	// 0.5.wait;
	/*
	q.utils.openFiles("gen", ["*"]); // */



	///////////   AUX-EFFECTS   ///////////////////////
	"loading AUX EFX...".inform;
	// m.loadAux(
	// 	name:          "reverbAux",
	// 	numChans:      m.config.numChans,
	// 	defaultInGain: 0.3
	// );

	///////////   MASTER-EFFECTS   ///////////////////////
	// q.utils.loadFiles("efx", ["*fx*", "*master*"]);

	{
		Out.ar(0,
			Limiter.ar(
				LeakDC.ar(In.ar(0, 2)),
				0.9,
				0.05
			)
		)
	}.play(m.server.defaultGroup, addAction: \addAfter)
});
);





(
///////////    CONTROLLERS	  ///////////////////////
"loading CONTROLLERS...".inform;

m.loadFiles(\control, [
	"NdefMixer",
	"rangeGUI",
	// "pushPullOSC",
	// "soundSelector-KeyPlayer"
]);

/*
m.openFiles(\control, [
"NdefMixer",
"pushPullOSC",
"soundSelector-KeyPlayer"
]);
*/

///////////    MAPPING   	  ///////////////////////
/*"loading MAPPING...".inform;
(
m.loadFiles("map", [
"keyPlayerMapping"
]);
);

{m.utils.generatorSelectAction(m.getNdefGens.first.key);}.defer;*/


);


