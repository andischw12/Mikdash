using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//[ExecuteInEditMode]
public class Doingthings : MonoBehaviour
{
   
    [SerializeField] GameObject Parts;
    [SerializeField] GameObject Full;
    [SerializeField] GameObject Target;
    [SerializeField] Transform[] PartsArr;
    [SerializeField] Transform[] FullsArr;
    [SerializeField] Transform[] TargetArr;
    [SerializeField] MeshFilter[] MeshFilterArr;

    // Start is called before the first frame update
    void Start()
    {
        PartsArr = Parts.GetComponentsInChildren<Transform>();
        //FullsArr = Full.GetComponentsInChildren<Transform>();
        TargetArr = new Transform[FullsArr.Length];
        //ChangeMaterials();
        MeshFilterArr = Parts.GetComponentsInChildren<MeshFilter>();
        ChangeMesh();
    }
    

    void ChangeMesh() 
    {
        Mesh[] meshArr =  new Mesh[MeshFilterArr.Length];
        for(int i=0;i<meshArr.Length;i++)
        {
            meshArr[i] = MeshFilterArr[i].sharedMesh;
        }

        foreach(MeshFilter MF in MeshFilterArr) 
        {
            foreach(Mesh M in meshArr) 
            {
                if(MF.mesh.vertexCount>156 &&  MF.mesh.vertexCount == M.vertexCount && MF.name[0]==M.name[0]&& MF.sharedMesh.triangles.Length == M.triangles.Length) 
                {
                    Debug.Log(M.name + " and " + MF.name);
                    MF.sharedMesh = M;
                    break;
                }
            }
        }

    }

    void ChangeMaterials() 
    {
        foreach (Transform PartArr in PartsArr) 
        {
            int i = 0;
            foreach (Transform FullArr in FullsArr) 
            {
               
                if (FullArr.name.Equals(PartArr.name) && FullArr.GetComponent<MeshRenderer>()!=null) 
                {
                    
                    
                    Debug.Log("Found identical");
                    PartArr.position = FullArr.position;
                    PartArr.rotation = FullArr.rotation;
                    PartArr.GetComponent<MeshRenderer>().sharedMaterial= FullArr.GetComponent<MeshRenderer>().sharedMaterial;
                    
                    break;
                }
                i++;
            }
        }
    }
}
