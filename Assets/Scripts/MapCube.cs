using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class MapCube : MonoBehaviour
{

    private GameObject turretGO;
    private TurretData turretData;

    public GameObject buildEffect;

    private Color normalColor;
    private bool isUpgraded = false;

    private void Start()
    {
        normalColor = GetComponent<MeshRenderer>().material.color;
    }

    private void OnMouseDown()
    {
        if (EventSystem.current.IsPointerOverGameObject() == true) return;
        if (turretGO != null)
        {
            BuildManager.Instance.ShowUpgradeUI(this,transform.position, isUpgraded);
        }
        else
        {
            BuildTurret();
        }
    }

    private void BuildTurret()
    {
        turretData = BuildManager.Instance.selectedTurretData;
        if (turretData == null || turretData.turretPrefab == null) return;

        if (BuildManager.Instance.IsEnough(turretData.cost)==false)
        {
            return;
        }

        BuildManager.Instance.ChangeMoney(-turretData.cost);

        turretGO = InstantiateTurret(turretData.turretPrefab);
    }

    private void OnMouseEnter()
    {
        if (turretGO == null && EventSystem.current.IsPointerOverGameObject() == false)
        {
            GetComponent<MeshRenderer>().material.color = normalColor*0.3f;
        }
    }
    private void OnMouseExit()
    {
        GetComponent<MeshRenderer>().material.color = normalColor;
    }

    public void OnTurretUpgrade()
    {
        if (BuildManager.Instance.IsEnough(turretData.costUpgraded))
        {
            isUpgraded = true;
            BuildManager.Instance.ChangeMoney(-turretData.costUpgraded);
            Destroy(turretGO);
            turretGO = InstantiateTurret(turretData.turretUpgradedPrefab);
        }
    }

    public void OnTurretDestroy()
    {
        Destroy(turretGO);
        turretData = null;
        turretGO = null;
        GameObject go = GameObject.Instantiate(buildEffect, transform.position, Quaternion.identity);
        Destroy(go, 2);
    }

    private GameObject InstantiateTurret(GameObject prefab)
    {
        GameObject turretGo = GameObject.Instantiate(prefab, transform.position, Quaternion.identity);
        GameObject go = GameObject.Instantiate(buildEffect, transform.position, Quaternion.identity);
        Destroy(go, 2);
        return turretGo;
    }
}
