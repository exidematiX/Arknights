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
            BuildManager.Instance.ShowUpgradeUI(this, transform.position, isUpgraded);
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

        if (BuildManager.Instance.IsEnough(turretData.cost) == false)
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
            GetComponent<MeshRenderer>().material.color = normalColor * 0.3f;
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

    // private GameObject InstantiateTurret(GameObject prefab)
    // {
    //     GameObject turretGo = GameObject.Instantiate(prefab, transform.position, Quaternion.identity);
    //     GameObject go = GameObject.Instantiate(buildEffect, transform.position, Quaternion.identity);
    //     Destroy(go, 2);
    //     return turretGo;
    // }
    // ...existing code...
    private GameObject InstantiateTurret(GameObject prefab)
    {
        // 根据预制体类型调整生成位置
        Vector3 spawnPosition = transform.position;
        
        // 如果是带有Rigidbody的模型（比如女孩），需要调整Y轴位置
        Rigidbody prefabRigidbody = prefab.GetComponent<Rigidbody>();
        if (prefabRigidbody != null)
        {
            // 获取碰撞体信息来调整位置
            Collider prefabCollider = prefab.GetComponent<Collider>();
            if (prefabCollider != null)
            {
                // 将生成位置调整到地面上方，避免卡入地下
                spawnPosition.y += prefabCollider.bounds.size.y * 0.5f + 1.3f;
            }
        }
        
        GameObject turretGo = GameObject.Instantiate(prefab, spawnPosition, Quaternion.identity);
        
        // 如果生成的是带Rigidbody的模型，可以暂时冻结Y轴旋转和位置
        Rigidbody rb = turretGo.GetComponent<Rigidbody>();
        if (rb != null)
        {
            rb.freezeRotation = true; // 防止模型倾倒
            // 或者更精确的约束：
            // rb.constraints = RigidbodyConstraints.FreezeRotation | RigidbodyConstraints.FreezePositionY;
        }
        
        GameObject go = GameObject.Instantiate(buildEffect, transform.position, Quaternion.identity);
        Destroy(go, 2);
        return turretGo;
    }
// ...existing code...
}
