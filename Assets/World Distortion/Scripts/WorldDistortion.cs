using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[Serializable, VolumeComponentMenu("Custom/World Distortion")]
[SupportedOnRenderPipeline(typeof(UniversalRenderPipelineAsset))]
public class WorldDistortion : VolumeComponent, IPostProcessComponent
{
    public FloatParameter startDistance = new(15f);
    public FloatParameter speed = new(0.6f);
    public Vector3Parameter scale = new(Vector3.zero);
    
    private static readonly int StartDistanceProperty = Shader.PropertyToID("_WorldDistortion_StartDistance");
    private static readonly int SpeedProperty = Shader.PropertyToID("_WorldDistortion_Speed");
    private static readonly int ScaleProperty = Shader.PropertyToID("_WorldDistortion_Scale");
    private static readonly int CameraDirectionProperty = Shader.PropertyToID("_WorldDistortion_CameraDirection");
    
    protected override void OnEnable()
    {
        base.OnEnable();
        RenderPipelineManager.beginCameraRendering += OnCameraRendering;
    }
    
    protected override void OnDisable()
    {
        base.OnDisable();
        RenderPipelineManager.beginCameraRendering -= OnCameraRendering;
    }
    
    private static void OnCameraRendering(ScriptableRenderContext context, Camera camera)
    {
        if (camera.cameraType.HasFlag(CameraType.SceneView))
        {
            Shader.SetGlobalVector(ScaleProperty, Vector3.zero);
        }
        else
        {
            var data = VolumeManager.instance.stack.GetComponent<WorldDistortion>();
            
            Shader.SetGlobalFloat(StartDistanceProperty, data.startDistance.value);
            Shader.SetGlobalFloat(SpeedProperty, data.speed.value);
            Shader.SetGlobalVector(ScaleProperty, data.scale.value);
            Shader.SetGlobalVector(CameraDirectionProperty, camera.transform.forward);
        }
    }
    
    public bool IsActive()
    {
        return scale.value != Vector3.zero;
    }
}
