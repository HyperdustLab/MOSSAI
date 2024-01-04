/** @format */

import { ethers, run, upgrades } from "hardhat";

async function main() {




    const MOSSAI_Storage = await ethers.deployContract("MOSSAI_Storage");
    await MOSSAI_Storage.waitForDeployment()



    const contract = await ethers.getContractFactory("Hyperdust_Island_Airdrop");
    const instance = await upgrades.deployProxy(contract);
    await instance.waitForDeployment();

    console.info("Hyperdust_Storage:", MOSSAI_Storage.target)


    await (await MOSSAI_Storage.setServiceAddress(instance.target)).wait()




    await (await instance.setContractAddress([
        "0x9bDaf3912e7b4794fE8aF2E748C35898265D5615",
        "0x1a41f86248E33e5327B26092b898bDfe04C6d8b4",
        "0x3Bf13fA640240D50298D21240c8B48eF01418384",
        "0xba09e4f4A54f3dB674C7B1fa729F4986F59FAFB8",
        MOSSAI_Storage.target
    ])).wait()


    console.info("contractFactory address:", instance.target);




}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
