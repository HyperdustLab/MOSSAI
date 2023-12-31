/** @format */

import { ethers, run } from "hardhat";

async function main() {
    const contract = await ethers.deployContract("MOSSAI_mNFT_Mint");
    await contract.waitForDeployment()

    await (await contract.setContractAddress(["0x3cc42e32ea76016CED99b98DEc0FD8D541Dc3B76", "0x1a41f86248E33e5327B26092b898bDfe04C6d8b4", "0x2EBDe3e744d0a870a17A2d51fd9079f14BF2137B", "0xAb0a5962659e59325ea6A3b0246444FC5e6024e0"])).wait()
    console.info("contractFactory address:", contract.target);

}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
