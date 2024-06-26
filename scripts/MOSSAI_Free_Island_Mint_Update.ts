/** @format */

import { ethers, run, upgrades } from 'hardhat'

async function main() {
  const Hyperdust_Render_Transcition = await ethers.getContractFactory('MOSSAI_Free_Island_Mint')

  const upgraded = await upgrades.upgradeProxy('0x5c8825666178AE91deE3c499A5293F220dD9FD56', Hyperdust_Render_Transcition)

  await (await upgraded.setContractAddress(['0x5197De6b2353d4720e08992c938eeb44E4F83206', '0xe0362E63F734A733dcF7BC002A2FE044AF41b37b', '0x7C94D4145c2d2ad2712B496DF6C27EEA5E0252C2', '0x1a41f86248E33e5327B26092b898bDfe04C6d8b4', '0xD11F65E5A55Cd7CA459a659734951901c8E57D30'])).wait()
}

// We recommend this pattern to be able to use async/await everywhere q
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
