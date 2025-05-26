using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class TriesUIController : MonoBehaviour
{
    [SerializeField]TextMeshProUGUI txt;
    int numOfTries = 1;

    private void OnEnable()
    {
        if (txt == null) return;
        txt = GetComponentInChildren<TextMeshProUGUI>();
        if (txt == null) { Debug.LogError("No text UI"); return; }
        numOfTries = 1;
        txt.text = $"x{numOfTries}";
    }


    public void UpdateTries()
    {
        if (txt == null) { Debug.LogError("No text UI"); return; }
        numOfTries++;
        txt.text = $"x{numOfTries}";
    }


    public void RestartTries()
    {
        if (txt == null) { Debug.LogError("No text UI"); return; }
        numOfTries = 0;
        txt.text = $"x{numOfTries}";
    }
}
