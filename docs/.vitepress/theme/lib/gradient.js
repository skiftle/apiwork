/**
 * Mesh Gradient - WebGL animated gradient background
 * Inspired by Stripe's implementation
 */

// Normalize hex color to [r, g, b] array (0-1 range)
function normalizeColor(hexCode) {
  const hex = hexCode.replace('#', '')
  return [
    parseInt(hex.substring(0, 2), 16) / 255,
    parseInt(hex.substring(2, 4), 16) / 255,
    parseInt(hex.substring(4, 6), 16) / 255
  ]
}

// Vertex shader - simple fullscreen quad
const vertexShader = `
attribute vec2 position;
varying vec2 v_uv;

void main() {
  v_uv = position * 0.5 + 0.5;
  gl_Position = vec4(position, 0.0, 1.0);
}
`

// Fragment shader - animated rounded diamonds (logo shape)
const fragmentShader = `
precision highp float;

uniform vec3 u_color1;
uniform vec3 u_color2;
uniform vec3 u_color3;
uniform vec3 u_color4;
uniform float u_time;
uniform vec2 u_resolution;

varying vec2 v_uv;

// Rhombus SDF (Inigo Quilez)
float ndot(vec2 a, vec2 b) { return a.x*b.x - a.y*b.y; }

float sdRhombus(vec2 p, vec2 b) {
  p = abs(p);
  float h = clamp(ndot(b - 2.0*p, b) / dot(b, b), -1.0, 1.0);
  float d = length(p - 0.5*b*vec2(1.0-h, 1.0+h));
  return d * sign(p.x*b.y + p.y*b.x - b.x*b.y);
}

// Rounded rhombus - subtract radius for rounding
float diamond(vec2 p, vec2 size) {
  float r = size.x * 0.10;
  return sdRhombus(p, size) - r;
}

// Premium soft diamond with smoother falloff
float softDiamond(vec2 uv, vec2 center, vec2 size, float blur) {
  vec2 p = uv - center;
  float d = diamond(p, size);

  if (blur <= 0.0) {
    return d < 0.0 ? 1.0 : 0.0;
  }

  // Smoother hermite falloff
  float edge = clamp(1.0 - d / (blur * size.x * 2.0), 0.0, 1.0);
  return edge * edge * (3.0 - 2.0 * edge);
}

// Fast noise for grain (Interleaved Gradient Noise)
float noise(vec2 n) {
  return fract(52.9829189 * fract(dot(n, vec2(0.06711056, 0.00583715))));
}

void main() {
  vec2 uv = v_uv;
  float t = u_time;

  // Animated blur - subtle pulsing
  float blur1 = 0.006 + pow(sin(t * 0.02 + 0.0), 2.0) * 0.012;
  float blur2 = 0.006 + pow(sin(t * 0.02 + 1.26), 2.0) * 0.012;
  float blur3 = 0.006 + pow(sin(t * 0.02 + 2.51), 2.0) * 0.012;
  float blur4 = 0.006 + pow(sin(t * 0.02 + 3.77), 2.0) * 0.012;
  float blur5 = 0.006 + pow(sin(t * 0.02 + 5.03), 2.0) * 0.012;

  // Animated opacity - subtle breathing
  float op1 = 0.6 + sin(t * 0.015 + 0.0) * 0.1;
  float op2 = 0.5 + sin(t * 0.018 + 1.5) * 0.1;
  float op3 = 0.45 + sin(t * 0.02 + 3.0) * 0.08;
  float op4 = 0.4 + sin(t * 0.022 + 4.5) * 0.08;
  float op5 = 0.35 + sin(t * 0.016 + 6.0) * 0.08;

  // Start with base color (lightest)
  vec3 color = u_color1;

  // Diamond layers (positions in aspect-corrected space)
  vec2 c1 = vec2(-0.3 + sin(t * 0.02) * 0.06, -0.2 + cos(t * 0.018) * 0.04);
  color = mix(color, u_color2, softDiamond(uv, c1, vec2(0.9), blur1) * op1);

  vec2 c2 = vec2(-0.1 + sin(t * 0.025) * 0.07, 0.0 + cos(t * 0.02) * 0.05);
  color = mix(color, u_color3, softDiamond(uv, c2, vec2(0.7), blur2) * op2);

  vec2 c3 = vec2(0.55 + sin(t * 0.028) * 0.07, 0.1 + cos(t * 0.024) * 0.05);
  color = mix(color, u_color4, softDiamond(uv, c3, vec2(0.55), blur3) * op3);

  vec2 c4 = vec2(0.8 + sin(t * 0.03) * 0.05, -0.05 + cos(t * 0.026) * 0.04);
  color = mix(color, u_color2, softDiamond(uv, c4, vec2(0.4), blur4) * op4);

  vec2 c5 = vec2(1.15 + sin(t * 0.022) * 0.04, -0.1 + cos(t * 0.024) * 0.04);
  color = mix(color, u_color3, softDiamond(uv, c5, vec2(0.5), blur5) * op5);

  // Fine grain (removes banding, adds sophistication)
  float grain = (noise(gl_FragCoord.xy) - 0.5) * 0.012;
  color += vec3(grain);

  gl_FragColor = vec4(color, 1.0);
}
`

class MiniGL {
  constructor(canvas, width, height) {
    this.canvas = canvas
    this.gl = canvas.getContext('webgl', {
      antialias: true,
      alpha: true,
      premultipliedAlpha: false
    })

    if (!this.gl) {
      console.warn('WebGL not supported')
      return
    }

    this.meshes = []
    this.setSize(width, height)
  }

  setSize(width, height) {
    this.width = width
    this.height = height
    this.canvas.width = width
    this.canvas.height = height
    this.gl?.viewport(0, 0, width, height)
  }

  createShader(type, source) {
    const gl = this.gl
    const shader = gl.createShader(type)
    gl.shaderSource(shader, source)
    gl.compileShader(shader)

    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      console.error('Shader compile error:', gl.getShaderInfoLog(shader))
      gl.deleteShader(shader)
      return null
    }

    return shader
  }

  createProgram(vertexSource, fragmentSource) {
    const gl = this.gl
    const vertexShader = this.createShader(gl.VERTEX_SHADER, vertexSource)
    const fragmentShader = this.createShader(gl.FRAGMENT_SHADER, fragmentSource)

    if (!vertexShader || !fragmentShader) return null

    const program = gl.createProgram()
    gl.attachShader(program, vertexShader)
    gl.attachShader(program, fragmentShader)
    gl.linkProgram(program)

    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
      console.error('Program link error:', gl.getProgramInfoLog(program))
      return null
    }

    return program
  }

  render() {
    const gl = this.gl
    if (!gl) return

    gl.clearColor(0, 0, 0, 0)
    gl.clear(gl.COLOR_BUFFER_BIT)

    for (const mesh of this.meshes) {
      mesh.render()
    }
  }
}

class Mesh {
  constructor(minigl, program) {
    this.minigl = minigl
    this.gl = minigl.gl
    this.program = program
    this.uniforms = {}

    this.setupBuffers()
  }

  setupBuffers() {
    const gl = this.gl

    // Fullscreen quad (two triangles)
    const positions = new Float32Array([
      -1, -1,
       1, -1,
      -1,  1,
       1,  1
    ])

    this.positionBuffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, this.positionBuffer)
    gl.bufferData(gl.ARRAY_BUFFER, positions, gl.STATIC_DRAW)
  }

  setUniform(name, type, value) {
    this.uniforms[name] = { type, value }
  }

  render() {
    const gl = this.gl
    gl.useProgram(this.program)

    // Bind position attribute
    const positionLocation = gl.getAttribLocation(this.program, 'position')
    gl.bindBuffer(gl.ARRAY_BUFFER, this.positionBuffer)
    gl.enableVertexAttribArray(positionLocation)
    gl.vertexAttribPointer(positionLocation, 2, gl.FLOAT, false, 0, 0)

    // Set uniforms
    for (const [name, { type, value }] of Object.entries(this.uniforms)) {
      const location = gl.getUniformLocation(this.program, name)
      if (location === null) continue

      switch (type) {
        case '1f':
          gl.uniform1f(location, value)
          break
        case '2f':
          gl.uniform2f(location, value[0], value[1])
          break
        case '3f':
          gl.uniform3f(location, value[0], value[1], value[2])
          break
      }
    }

    // Draw fullscreen quad
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)
  }
}

export class Gradient {
  constructor(options = {}) {
    this.colors = options.colors || [
      '#fef7f7', // very light coral (almost white)
      '#fde8e8', // light coral
      '#fcd4d4', // soft coral
      '#fab5b5'  // medium coral
    ]
    this.amplitude = options.amplitude || 200
    this.seed = options.seed || 5
    this.speed = options.speed || 1.0

    this.time = 0
    this.playing = false
    this.minigl = null
    this.mesh = null
    this.animationFrame = null
  }

  initGradient(canvas) {
    if (!canvas) return

    this.canvas = canvas
    this.resize()

    // Check if canvas has dimensions
    if (this.width === 0 || this.height === 0) {
      console.warn('MeshGradient: Canvas has no dimensions')
      return
    }

    this.minigl = new MiniGL(canvas, this.width, this.height)
    if (!this.minigl.gl) {
      console.warn('MeshGradient: WebGL not available')
      return
    }

    const program = this.minigl.createProgram(vertexShader, fragmentShader)
    if (!program) {
      console.warn('MeshGradient: Failed to create shader program')
      return
    }

    this.mesh = new Mesh(this.minigl, program)
    this.minigl.meshes.push(this.mesh)

    // Set initial uniforms
    const colors = this.colors.map(normalizeColor)
    this.mesh.setUniform('u_color1', '3f', colors[0])
    this.mesh.setUniform('u_color2', '3f', colors[1])
    this.mesh.setUniform('u_color3', '3f', colors[2])
    this.mesh.setUniform('u_color4', '3f', colors[3])
    this.mesh.setUniform('u_time', '1f', 0)
    this.mesh.setUniform('u_resolution', '2f', [this.width, this.height])

    // Event listeners
    this.resizeHandler = () => this.handleResize()
    window.addEventListener('resize', this.resizeHandler)

    this.play()
  }

  resize() {
    const rect = this.canvas.getBoundingClientRect()
    const dpr = Math.min(window.devicePixelRatio || 1, 2)
    this.width = rect.width * dpr
    this.height = rect.height * dpr
  }

  handleResize() {
    this.resize()
    if (this.minigl) {
      this.minigl.setSize(this.width, this.height)
      if (this.mesh) {
        this.mesh.setUniform('u_resolution', '2f', [this.width, this.height])
      }
    }
  }

  updateColors(newColors) {
    if (!this.mesh) return
    this.colors = newColors
    const colors = this.colors.map(normalizeColor)
    this.mesh.setUniform('u_color1', '3f', colors[0])
    this.mesh.setUniform('u_color2', '3f', colors[1])
    this.mesh.setUniform('u_color3', '3f', colors[2])
    this.mesh.setUniform('u_color4', '3f', colors[3])
  }

  play() {
    if (this.playing) return
    this.playing = true
    this.animate()
  }

  pause() {
    this.playing = false
    if (this.animationFrame) {
      cancelAnimationFrame(this.animationFrame)
      this.animationFrame = null
    }
  }

  animate() {
    if (!this.playing || !this.mesh) return

    this.time += 0.01 * this.speed
    this.mesh.setUniform('u_time', '1f', this.time)
    this.minigl.render()

    this.animationFrame = requestAnimationFrame(() => this.animate())
  }

  disconnect() {
    this.pause()
    window.removeEventListener('resize', this.resizeHandler)
  }
}
