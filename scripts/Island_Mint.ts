/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const Island_Mint = await ethers.getContractFactory('Island_Mint')
  const instance = await upgrades.deployProxy(Island_Mint, [process.env.ADMIN_Wallet_Address])
  await (await instance.setContractAddress(['0xe05599cA89aA8Af73Ef688350800B1444543aF6D', '0x141333a8797db93C217Fb12D9dDd01A255d0fF77', '0xCAf8B831814678116d2f311540b5970C5aA0792B', '0x250a7629d076581d3713f016727204341865920C'])).wait()

  const IHyperAGI_Roles_Cfg = await ethers.getContractAt('IHyperAGI_Roles_Cfg', '0x250a7629d076581d3713f016727204341865920C')

  await (await IHyperAGI_Roles_Cfg.addAdmin(instance.target)).wait()

  const MOSSAI_Island = await ethers.getContractAt('MOSSAI_Island', '0xe05599cA89aA8Af73Ef688350800B1444543aF6D')

  await (await MOSSAI_Island.set_IslandMintAddress(instance.target)).wait()

  console.info('contractFactory address:', instance.target)
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
