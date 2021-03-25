using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomClipBox : MonoBehaviour
{
    Dictionary<MeshRenderer, MeshFilter> dictionaryOfGraphic;
    //[SerializeField]
    public List<MeshRenderer> renderers;
    private List<MeshFilter> filters;
    public Vector3 Pos;
    public Vector3 Scal;
    public Quaternion Rot;
    public Matrix4x4 m;
    private bool update;

    private void Awake()
    {
        dictionaryOfGraphic = new Dictionary<MeshRenderer, MeshFilter>();
        update = false;
    }

   

    private void OnDisable()
    {
        foreach (var rend in renderers)
        {
            DisableClip(rend);

        }
    }
    void Update()
    {
        Pos = transform.position;
        Scal = transform.lossyScale * 0.5f;
        Rot = transform.rotation;

        foreach (var rend in renderers)
        {
            bool hasProp0 = rend.material.HasProperty("CubeScalee");
            bool hasProp1 = rend.material.HasProperty("CurveInverseTransformmm");

            float lenght0 = Scal.magnitude * 4.0f;
            Vector3 position0 = transform.position;
            Vector3 position1 = rend.transform.position;
            float distance = (position0 - position1).magnitude;

            if (hasProp0 && distance < lenght0 && rend.gameObject.activeInHierarchy)
            {
                rend.material.SetVector("CubeScalee", new Vector4(Scal.x, Scal.y, Scal.z, 0.0f));
                Matrix4x4 matrix4X4 = Matrix4x4.TRS(Pos, Rot, Vector3.one).inverse;
                m = matrix4X4;
                rend.material.SetMatrix("CurveInverseTransformmm", matrix4X4);
                update = true;
            }
            else if (update)
            {
                DisableClip(rend);
                update = false;
            }
        }
    }

    public void DisableClip(MeshRenderer rend)
    {
        rend.material.SetVector("CubeScalee", new Vector4(0.0f, 0.0f, 0.0f, 0.0f));
        Matrix4x4 matrix4X4 = Matrix4x4.TRS(Vector3.zero, Quaternion.identity, Vector3.one).inverse;
        m = matrix4X4;
        rend.material.SetMatrix("CurveInverseTransformmm", matrix4X4);
    }


#if UNITY_EDITOR
    private void OnDrawGizmos()
    {

        if (enabled)
        {
            Gizmos.color = Color.cyan;
            Vector3 scale = transform.lossyScale;
            Gizmos.DrawWireCube(transform.position, scale);
        }
    }
#endif
}
