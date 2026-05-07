package shaders;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

class CutGlitchShader extends FlxBasic {
    public var shader(default, null):CGLShader = new CGLShader();
    
    public var iTime:Float = 0;
    public var amount(default, set):Float = 0; //0.5
    public var speed(default, set):Float = 0; //32

    public function new() {
        super();
        // Initialize shader values if needed
        setShaderValues();
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        iTime += elapsed;
        shader.data.iTime.value = [iTime];
    }

    public function set_amount(v:Float):Float {
        amount = v;
        shader.data.AMT.value = [amount];
        return v;
    }

    public function set_speed(v:Float):Float {
        speed = v;
        shader.data.SPEED.value = [speed];
        return v;
    }

    public function get_amount() {
        return shader.data.AMT.value;
    }

    public function get_speed() {
        return shader.data.SPEED.value;
    }

    private function setShaderValues():Void {
        shader.data.AMT.value = [amount];
        shader.data.SPEED.value = [speed];
        shader.data.iTime.value = [iTime];
    }
}

class CGLShader extends FlxShader {
    @:glFragmentSource('
        uniform float AMT;
        uniform float SPEED;
        uniform float iTime;

        varying vec2 openfl_TextureCoordv;
        uniform sampler2D openfl_Texture;
        uniform vec2 openfl_TextureSize;

        float random2d(vec2 n) {
            return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
        }

        float randomRange(in vec2 seed, in float min, in float max) {
            return min + random2d(seed) * (max - min);
        }

        float insideRange(float v, float bottom, float top) {
            return step(bottom, v) - step(top, v);
        }

        void main(void) {
            float time = floor(iTime * SPEED);
            vec2 fragCoord = openfl_TextureCoordv * openfl_TextureSize;
            vec2 uv = fragCoord.xy / openfl_TextureSize.xy;
            vec3 outCol = texture2D(openfl_Texture, uv).rgb;
            float maxOffset = AMT / 32.0;

            for (float i = 0.0; i < 10.0 * AMT; i += 0.25) {
                float sliceY = random2d(vec2(time, 2345.0 + float(i)));
                float sliceH = random2d(vec2(time, 925.0 + float(i))) * 0.075;
                float hOffset = randomRange(vec2(time, 25.0 + float(i)), -maxOffset, maxOffset);
                vec2 uvOff = uv;
                uvOff.x += hOffset;

                if (insideRange(uv.y, sliceY, fract(sliceY + sliceH)) == 1.0) {
                    outCol = texture2D(openfl_Texture, uvOff).rgb;
                }
            }

            gl_FragColor = vec4(outCol, 1.0);
        }
    ')

    public function new() {
        super();
    }
}
