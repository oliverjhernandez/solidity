import Web3 from 'web3'
import { AbiItem } from 'web3-utils'
import MyContract from '../build/contracts/MyContract.json'

async function main() {
  const providerUrl = 'https://sepolia.infura.io/v3/6a90b9fe563b4ea294ca1681eff99509'
  const web3 = new Web3(providerUrl)
  const abi: AbiItem[] = [
    {
      constant: true,
      inputs: [],
      name: 'getCurrentImplementation',
      outputs: [{ name: '', type: 'address' }],
      payable: false,
      stateMutability: 'view',
      type: 'function',
    },
  ]

  const contractAddress = '0x07865c6e87b9f70255377e024ace6630c1eaa37f'
  const contract = new web3.eth.Contract(abi, contractAddress, { gas: 500000 })

  const implementation = await contract.methods.getCurrentImplementation().call()
  console.log(`Current implementation: ${implementation}`)
}

main().catch((error) => {
  console.error(error)
  process.exit(1)
})
