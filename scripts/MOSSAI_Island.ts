/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {



    const MOSSAI_Storage = await ethers.deployContract("MOSSAI_Storage", [process.env.ADMIN_Wallet_Address]);
    await MOSSAI_Storage.waitForDeployment()



    const contract = await ethers.getContractFactory("MOSSAI_Island");
    const instance = await upgrades.deployProxy(contract, [process.env.ADMIN_Wallet_Address]);
    await instance.waitForDeployment();

    console.info("Hyperdust_Storage:", MOSSAI_Storage.target)


    await (await instance.setContractAddress(
        [
            "0x33e2f799dCF34df195f34664b243f318EB536B72",
            "0x2EBd0de3fD3250c70D4C4beDe1835D53A64Ea490",
            "0x92bf83aF19DE8bbBfC50dD96196668569D0C779a",
            "0x81cD3746573C5b6121d19b285D32D7233aEcB11b",
            "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615",
            MOSSAI_Storage.target,
            "0x7872Db8dCea6E3865C604a9D5dA9C5a2607Bb66a",
        ])).wait();


    const MOSSAI_Roles_Cfg = await ethers.getContractAt("Hyperdust_Roles_Cfg", "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615")

    await (await MOSSAI_Roles_Cfg.addAdmin(instance.target)).wait()

    await (await MOSSAI_Storage.setServiceAddress(instance.target)).wait()


    await (
        await instance.setDefParameter(
            "https://vniverse.s3.ap-east-1.amazonaws.com/upload/2023/8/10/13e02181-24b5-4e41-8481-4d7bb4886619.jpg",
            "https://s3.hyperdust.io/upload/2024/1/24/63241709-6683-404c-b35c-b5466a57dad3.7z",
            "83e56d1e198ac71e493706073e2547b99f35baa53801d7127ebe2448e04ce5f0"
        )
    ).wait();


    const Island_Mint = await ethers.getContractAt("Island_Mint", "0x7872Db8dCea6E3865C604a9D5dA9C5a2607Bb66a")


    await (await Island_Mint.setMOSSAIIslandAddres(instance.target)).wait()

    console.info("contractFactory address:", instance.target);

}

// We recommend this pattern to be able to use async/await everywhere q

// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
