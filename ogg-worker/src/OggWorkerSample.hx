import haxe.Timer;

import fs.core.File;
import audio.decoder.Decoder;
import audio.decoder.OggDecoder;

using NumberTools;

@await class OggWorkerSample {

    public function new() {
        trace('Ogg');

        test1();
    }

    @async public function test1() {
        var file = @await File.load('assets/test.ogg');

        Decoder.webAudioEnabled = true;

        var decoder = new OggDecoder(file);

        var start = 0;
        var end = decoder.length;

        trace('DECODING', end - start, file.length);

        // Decode the whole sample for testing
        @await decoder.decodeAll();

        var n = 0;
        var volume = 0.3;
        var yoyo = 1;

        // Create a sin wave audio source
        var audio = AudioPlayer
            .create()
            .useGenerator((out, sampleRate) -> for( i in 0...out.length >> 1 ) {
                var left = decoder.getSample(n, 0) * volume;
                var right = decoder.getSample(n, 1) * volume;
                
                out.set(i*2, left);
                out.set(i*2 + 1, right);

                n += yoyo;
                
                if (n >= end || n <= 0) {
                    yoyo *= -1;
                    n += yoyo;
                }
            })
            .play();

        // Stop it after 3 seconds
        Timer.delay(() -> audio.stop(), DateTools.seconds(3).int());
    }

    // Main entry point
    static public function main() {
        new OggWorkerSample();
    }
}