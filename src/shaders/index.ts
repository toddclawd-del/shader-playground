import { gradientConfig } from './gradient/config'
import { noiseConfig } from './noise/config'
import { bosShapesConfig } from './bos-shapes/config'
import { bosPatternsConfig } from './bos-patterns/config'
import { wavesConfig } from './waves/config'
import { textureConfig } from './texture/config'
import { liquidConfig } from './liquid/config'
import { raymarchingConfig } from './raymarching/config'
import { rippleConfig } from './ripple/config'
import { flowfieldConfig } from './flowfield/config'
import { auroraConfig } from './aurora/config'
import { glassConfig } from './glass/config'
import { holographicConfig } from './holographic/config'
import { voronoiConfig } from './voronoi/config'
import { domainWarpConfig } from './domain-warp/config'
import { juliaSetConfig } from './julia-set/config'
import { truchetTilesConfig } from './truchet-tiles/config'
// New shaders
import { gradientMeshConfig } from './gradient-mesh/config'
import { distortionConfig } from './distortion/config'
import { chromaticAberrationConfig } from './chromatic-aberration/config'
import { particleFieldConfig } from './particle-field/config'
import { reactionDiffusionConfig } from './reaction-diffusion/config'
import { fractalConfig } from './fractal/config'
import { noiseFieldConfig } from './noise-field/config'
import { voronoiAdvancedConfig } from './voronoi-advanced/config'
import type { ShaderConfig } from '../stores/shaderStore'

export const shaderRegistry: Record<string, ShaderConfig> = {
  gradient: gradientConfig,
  noise: noiseConfig,
  'bos-shapes': bosShapesConfig,
  'bos-patterns': bosPatternsConfig,
  waves: wavesConfig,
  texture: textureConfig,
  liquid: liquidConfig,
  raymarching: raymarchingConfig,
  ripple: rippleConfig,
  flowfield: flowfieldConfig,
  aurora: auroraConfig,
  glass: glassConfig,
  holographic: holographicConfig,
  voronoi: voronoiConfig,
  'domain-warp': domainWarpConfig,
  'julia-set': juliaSetConfig,
  'truchet-tiles': truchetTilesConfig,
  // New shaders
  'gradient-mesh': gradientMeshConfig,
  distortion: distortionConfig,
  'chromatic-aberration': chromaticAberrationConfig,
  'particle-field': particleFieldConfig,
  'reaction-diffusion': reactionDiffusionConfig,
  fractal: fractalConfig,
  'noise-field': noiseFieldConfig,
  'voronoi-advanced': voronoiAdvancedConfig,
}

export const shaderList = Object.entries(shaderRegistry).map(([id, config]) => ({
  id,
  name: config.name,
  description: config.description,
}))
