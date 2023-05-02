#extension GL_OES_standard_derivatives : enable
precision highp float;
uniform float u_time;
uniform vec2 u_resolution;

float smoothMin(float a, float b, float k) {
  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}

float sdf(vec2 position) {
  // Comment/uncomment these code to play around!
  float dist = 0.;

  // Demonstration of basic SDFs
  {
    vec2 point = position * 18.;
    dist = length(point) - 2.;

    {
      float distA = length(point) - 2.;
      float distB = length(point - vec2(3., 0)) - 2.;

      float a = distA, b = distB;
      dist = a;
      dist = b;

      dist = min(a, b);
      dist = max(a, b);
      dist = max(a, -b);
      dist = -b;
      dist = min(max(a, -b), max(-a, b));
      dist = a - 0.5;
      dist = a + 0.5;
      dist = smoothMin(a - 0.2, b + 0.2, 1.);
      dist = abs(a) - 0.25;
      dist = min(abs(max(a, 0.4 - b) + 0.2) - 0.2, b);
      dist = abs(mod(a, 2.) - 1.) - .3;
      dist = abs(mod(smoothMin(a - .5, b + .5, 1.), 2.) - 1.) - .3;
    }
  }

  // Describing the background image scene
  {
    vec2 p = position * 8.;

    p = vec2(p.x + p.y, p.x - p.y);
    p = mod(p + 1., 2.) - 1.;
    p = abs(p);

    {
      float distA = length(p) - .2;
      float distB = length(.4-p) - .36;
      float distC = max(p.x-.76, .4-p.x);
      float distD = max(p.y-.76, .4-p.y);
      float distE = max(distC, distD);
      float distF = min(distE, distB);
      float distG = .3 - length(p);
      float distH = max(distF, distG);
      float distI = min(distA, distH);

      dist = distA;
      dist = distB;
      dist = distC;
      dist = distD;
      dist = distE;
      dist = distF;
      dist = distG;
      dist = distH;
      dist = distI;
      dist = max(max(p.x-.76,.4-p.x),max(p.y-.76,.4-p.y));
      dist = min(length(p)-.2,max(min(dist,length(.4-p)-.36),.3-length(p)));
    }
  }

  return dist;
}

void main(void) {
  vec2 position = (gl_FragCoord.xy - u_resolution.xy / 2.) / u_resolution.yy;

  // Find the distance
  float dist = sdf(position);

  // Example shading
  float temp = 1. - pow(1. - clamp(abs(dist), 0., 1.), 2.);
  gl_FragColor = dist <= 0.
    ? mix(vec4(.843, .988, .439, 1.), vec4(1.), temp)
    : mix(vec4(0., 0., 0., 1.), vec4(0.208, 0.204, 0.2, 1.), temp);

  // Shading used in the background
  float color = sin(position.x*.3+.2) + sin((1.-position.y)* .7-.2)+.1;
  if (dist <= 0.) color *= 1. + exp(dist * 8.) * .2;
  gl_FragColor = vec4(vec3(color, color * 0.5, sin(color / 3.0 + position.x - position.y) * 0.75 ), 1.0);

  // Highlight/shadows
  // if (dist >= 0.) {
  //   gl_FragColor = vec4(vec3(gl_FragColor.rgb) * (mod(dist, 0.2) < 0.11 ? 1.5 : 1.), 1.);
  // } else {
  //   float dist2 = sdf(position + vec2(0., 1.) * 0.02);
  //   gl_FragColor = vec4(mix(gl_FragColor.rgb - 0.3, gl_FragColor.rgb, smoothstep(-0.8, 0.8, dist2)), 1.);
  // }
}

