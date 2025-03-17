//UNITY_SHADER_NO_UPGRADE
#ifndef WORLD_DISTORTION_INCLUDED
#define WORLD_DISTORTION_INCLUDED

float _WorldDistortion_StartDistance;
float _WorldDistortion_Speed;
float3 _WorldDistortion_Scale;
float3 _WorldDistortion_CameraDirection;

void _WorldDistortion_RotateAboutAxis_float(float3 In, float3 Axis, float Rotation, out float3 Out)
{
    Rotation = radians(Rotation);
    
    float s = sin(Rotation);
    float c = cos(Rotation);
    float one_minus_c = 1.0 - c;

    Axis = normalize(Axis);

    float3x3 rot_mat = {
        one_minus_c * Axis.x * Axis.x + c, one_minus_c * Axis.x * Axis.y - Axis.z * s, one_minus_c * Axis.z * Axis.x + Axis.y * s,
        one_minus_c * Axis.x * Axis.y + Axis.z * s, one_minus_c * Axis.y * Axis.y + c, one_minus_c * Axis.y * Axis.z - Axis.x * s,
        one_minus_c * Axis.z * Axis.x - Axis.y * s, one_minus_c * Axis.y * Axis.z + Axis.x * s, one_minus_c * Axis.z * Axis.z + c
    };

    Out = mul(rot_mat, In);
}

void _WorldDistortion_RotateAboutAxis_half(half3 In, half3 Axis, half Rotation, out half3 Out)
{
    Rotation = radians(Rotation);
    
    half s = sin(Rotation);
    half c = cos(Rotation);
    half one_minus_c = 1.0 - c;

    Axis = normalize(Axis);

    half3x3 rot_mat = {
        one_minus_c * Axis.x * Axis.x + c, one_minus_c * Axis.x * Axis.y - Axis.z * s, one_minus_c * Axis.z * Axis.x + Axis.y * s,
        one_minus_c * Axis.x * Axis.y + Axis.z * s, one_minus_c * Axis.y * Axis.y + c, one_minus_c * Axis.y * Axis.z - Axis.x * s,
        one_minus_c * Axis.z * Axis.x - Axis.y * s, one_minus_c * Axis.y * Axis.z + Axis.x * s, one_minus_c * Axis.z * Axis.z + c
    };

    Out = mul(rot_mat, In);
}

void WorldDistortion_float(float3 InPosition, float StartDistance, float Speed, float3 Scale, out float3 OutPosition)
{
    float vertexDistance = max(distance(_WorldSpaceCameraPos, InPosition), 0.0);
    
    if (vertexDistance < StartDistance - 2.0)
    {
        OutPosition = InPosition;
        return;
    }
    
    float t = _Time.y * Speed;
    float timeSin = sin(t);
    float timeCos = cos(t);

    float w1 = max(0, vertexDistance - StartDistance);
    float w2 = tanh(vertexDistance - StartDistance - 2.0) + 1.0;
    float w3 = max(w1, w2);

    float3 d_x = cross(_WorldDistortion_CameraDirection, float3(0.0, -1.0, 0.0)) * (w3 * Scale.x * timeCos);
    float3 d_y = float3(0.0, w3 * Scale.y * timeSin, 0.0);
    float d_z = w3 * Scale.z * timeCos;

    _WorldDistortion_RotateAboutAxis_float(InPosition + d_x + d_y, _WorldDistortion_CameraDirection * float3(1.0, 0.0, 1.0), d_z, OutPosition);
}

void WorldDistortion_half(half3 InPosition, half StartDistance, half Speed, half3 Scale, out half3 OutPosition)
{
    half vertexDistance = max(distance(_WorldSpaceCameraPos, InPosition), 0.0);
    
    if (vertexDistance < StartDistance - 2.0)
    {
        OutPosition = InPosition;
        return;
    }
    
    half t = _Time.y * Speed;
    half timeSin = sin(t);
    half timeCos = cos(t);

    half w1 = max(0, vertexDistance - StartDistance);
    half w2 = tanh(vertexDistance - StartDistance - 2.0) + 1.0;
    half w3 = max(w1, w2);

    half3 d_x = cross(_WorldDistortion_CameraDirection, half3(0.0, -1.0, 0.0)) * (w3 * Scale.x * timeCos);
    half3 d_y = half3(0.0, w3 * Scale.y * timeSin, 0.0);
    half d_z = w3 * Scale.z * timeCos;

    _WorldDistortion_RotateAboutAxis_half(InPosition + d_x + d_y, _WorldDistortion_CameraDirection * half3(1.0, 0.0, 1.0), d_z, OutPosition);
}

void WorldDistortionGlobal_float(float3 InPosition, out float3 OutPosition)
{
    if (_WorldDistortion_Scale.x != 0.0 || _WorldDistortion_Scale.y != 0.0 || _WorldDistortion_Scale.z != 0.0)
    {
        WorldDistortion_float(
            InPosition,
            _WorldDistortion_StartDistance,
            _WorldDistortion_Speed,
            _WorldDistortion_Scale,
            OutPosition);
    }
    else
    {
        OutPosition = InPosition;
    }
}

void WorldDistortionGlobal_half(half3 InPosition, out half3 OutPosition)
{
    if (_WorldDistortion_Scale.x != 0.0 || _WorldDistortion_Scale.y != 0.0 || _WorldDistortion_Scale.z != 0.0)
    {
        WorldDistortion_half(
            InPosition,
            _WorldDistortion_StartDistance,
            _WorldDistortion_Speed,
            _WorldDistortion_Scale,
            OutPosition);
    }
    else
    {
        OutPosition = InPosition;
    }
}

#endif
