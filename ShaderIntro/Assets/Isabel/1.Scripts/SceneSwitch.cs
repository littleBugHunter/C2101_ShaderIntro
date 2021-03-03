using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement; //Include when you want to use scene change 
//set Steam vr ?

public class SceneSwitch : MonoBehaviour
{
    public int WhichSceneLoad;
    //---------------------------When Using Button----------------------------------------
    // public void ScenSwitch()
    //{
    // SceneManager.LoadScene(1); //Udes to laod scene (Scne you wanna load in File Build Settings defind)
    //}

    //---------------------------When Using Trigger----------------------------------------
    private void OnTriggerEnter(Collider other)
    {
        SceneManager.LoadScene(WhichSceneLoad);
    }

}
