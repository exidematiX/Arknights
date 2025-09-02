using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class BuildManager : MonoBehaviour
{
    public static BuildManager Instance { get; private set; }

    public TurretData standardTurretData;
    public TurretData missileTurretData;
    public TurretData laserTurretData;

    public TurretData selectedTurretData;

    public TextMeshProUGUI moneyText;
    private Animator moneyTextAnim;
    private int money = 1000;

    public UpgradeUI upgradeUI;
    private MapCube upgradeCube;

    
    private void Awake()
    {
        Instance = this;
        moneyTextAnim = moneyText.GetComponent<Animator>();
    }


    public void OnStandardSelected(bool isOn)
    {
        if (isOn)
        {
            selectedTurretData = standardTurretData;
        }
    }
    public void OnMissileSelected(bool isOn)
    {
        if (isOn)
        {
            selectedTurretData = missileTurretData;
        }
    }
    public void OnLaserSelected(bool isOn)
    {
        if (isOn)
        {
            selectedTurretData = laserTurretData;
        }
    }

    public bool IsEnough(int need)
    {
        if (need <= money)
        {
            return true;
        }
        else
        {
            MoneyFlicker();
            return false;
        }
    }
    public void ChangeMoney(int value)
    {
        this.money += value;
        moneyText.text = "гд:"+money.ToString();
    }
    private void MoneyFlicker()
    {
        moneyTextAnim.SetTrigger("flicker");
    }

    public void ShowUpgradeUI(MapCube cube, Vector3 position,bool isDisableUpgrade)
    {
        upgradeCube = cube;
        upgradeUI.Show(position, isDisableUpgrade);
    }
    public void HideUpgradeUI()
    {
        upgradeUI.Hide();
    }

    public void OnTurretUpgrade()
    {
        upgradeCube?.OnTurretUpgrade();
        HideUpgradeUI();
    }
    public void OnTurretDestroy()
    {
        upgradeCube?.OnTurretDestroy();
        HideUpgradeUI();
    }
}
