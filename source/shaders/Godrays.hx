package shaders;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;
import StringTools;

class GodRaysShader extends FlxBasic {
    public var shader(default, null):GR = new GR();

    private var lightIntensity:Float = 0.0;
    private var lightAlpha:Float = 1.0;
    private var lightDecay:Float = 1.0;
    private var circleSize:Float = 1.0;
    private var raysColor:Array<Float> = [0.0, 0.0, 0.0]; // Default color: black
    private var lightPosX:Float = 0.0;
    private var lightPosY:Float = 0.0;

    public function new() {
        super();

        shader.data._LightPos.value = [lightPosX, lightPosY];
        shader.data.Alpha.value = [lightAlpha];
        shader.data.Exposure.value = [lightIntensity];
        shader.data.MyDecay.value = [lightDecay];
        shader.data.CircleSize.value = [circleSize];
        shader.data.RaysColor.value = raysColor; // Initialize rays color
    }

    public function setLightPosition(x:Float, y:Float):Void {
        lightPosX = x;
        lightPosY = y;
        shader.data._LightPos.value = [x, y];
    }

    public function setLightAlpha(value:Float):Void {
        lightAlpha = value;
        shader.data.Alpha.value = [lightAlpha];
    }

    public function setLightIntensity(value:Float):Void {
        lightIntensity = value;
        shader.data.Exposure.value = [lightIntensity];
    }

    public function setLightDecay(value:Float):Void {
        lightDecay = value;
        shader.data.MyDecay.value = [lightDecay];
    }

    public function setCircleSize(value:Float):Void {
        circleSize = value;
        shader.data.CircleSize.value = [circleSize];
    }

    public function setRaysColor(r:Float, g:Float, b:Float):Void {
        raysColor = [r, g, b];
        shader.data.RaysColor.value = raysColor; // Update the shader's rays color
    }

    public function setRaysColorFromHex(hex:String = "000000"):Void {
        var r = Std.parseInt(hex.substr(0, 2)) / 255.0;
        var g = Std.parseInt(hex.substr(2, 2)) / 255.0;
        var b = Std.parseInt(hex.substr(4, 2)) / 255.0;
        setRaysColor(r, g, b); // Set color using normalized values
    }

    public function getRaysColorString():String {
        var r = StringTools.lpad(Std.string(Math.round(raysColor[0] * 255)), "0", 2);
        var g = StringTools.lpad(Std.string(Math.round(raysColor[1] * 255)), "0", 2);
        var b = StringTools.lpad(Std.string(Math.round(raysColor[2] * 255)), "0", 2);
        return r + g + b;
    }

    // Getter methods
    public function getLightPosition():Array<Float> {
        return [lightPosX, lightPosY];
    }

    public function getLightAlpha():Float {
        return lightAlpha;
    }

    public function getLightIntensity():Float {
        return lightIntensity;
    }

    public function getLightDecay():Float {
        return lightDecay;
    }

    public function getCircleSize():Float {
        return circleSize;
    }
}

class GR extends FlxShader {
    @:glFragmentSource('
    #pragma header
    uniform float Exposure;
    uniform float MyDecay;
    uniform float CircleSize;
    uniform vec2 _LightPos;
    uniform float Alpha;
    uniform vec3 RaysColor; // Changed to vec3 for RGB color
    uniform sampler2D openfl_Texture;

    vec4 occlusion(vec2 q) {
        float i = length((q - _LightPos) * vec2(openfl_TextureSize.x / openfl_TextureSize.y, 1.0)) / CircleSize;
        i = 1.0 - clamp(i * i, 0.0, Alpha);
        
        vec4 bg = vec4(RaysColor, 1.0) * i; // Multiply by RaysColor
        vec4 fg = texture2D(openfl_Texture, q);
        float k = 1.0 - fg.a;

        return mix(fg, bg, k * Alpha);
    }

    void main() {
        vec2 uv = openfl_TextureCoordv.xy;
        vec4 color = vec4(0, 0, 0, 1.0);
        float illuminationDecay = 1.0;

        for (int i = 0; i < 50; i++) {
            vec2 uvSample = mix(uv, _LightPos, float(i) / 49.0);
            vec4 sample = occlusion(uvSample);

            sample *= illuminationDecay * (1.0 / 50.0);
            color += sample;

            illuminationDecay *= (1.0 - MyDecay / 50.0);
        }

        // Use the background color as the base and add the godrays
        gl_FragColor = color * Exposure + texture2D(openfl_Texture, uv);
    }
    ')  

    public function new() {
        super();
    }
}