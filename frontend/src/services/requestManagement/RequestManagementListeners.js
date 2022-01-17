import { RequestManagement } from './RequestManagement'
import store from '../../state'

export const requestManagementListeners = async () => {
  const contract = await RequestManagement.get()
  if (!contract) {
    throw new Error('requestManagementListeners failed')
  }

  offerCreatedListener(contract)
  requestCreatedListener(contract)
  requestGrantedListener(contract)
  withdrawListener(contract)
  debtPaidListener(contract)
}

const requestCreatedListener = (contract) => {
  let txHash
  contract.events.RequestCreated().on('data', (event) => {
    if (txHash !== event.transactionHash) {
      txHash = event.transactionHash
      store.dispatch('requestManagement/getRequests')
      store.dispatch('requestManagement/getOffers')
    }
  })
}

const requestGrantedListener = (contract) => {
  let txHash
  contract.events.RequestGranted().on('data', (event) => {
    if (txHash !== event.transactionHash) {
      txHash = event.transactionHash
      store.dispatch('requestManagement/getRequests')
      store.dispatch('requestManagement/getOffers')
    }
  })
}

const offerCreatedListener = (contract) => {
  let txHash
  contract.events.OfferCreated().on('data', (event) => {
    if (txHash !== event.transactionHash) {
      console.log("MMMMMMMMMMMMMMMM1111: " + event.transactionHash)
      txHash = event.transactionHash
      store.dispatch('requestManagement/getOffers')
    }
  })
}

const withdrawListener = (contract) => {
  let txHash
  contract.events.Withdraw().on('data', (event) => {
    if (txHash !== event.transactionHash) {
      txHash = event.transactionHash
      store.dispatch('requestManagement/getRequests')
      store.dispatch('requestManagement/getOffers')
    }
  })
}

const debtPaidListener = (contract) => {
  let txHash
  contract.events.DebtPaid().on('data', (event) => {
    if (txHash !== event.transactionHash) {
      txHash = event.transactionHash
      store.dispatch('requestManagement/getRequests')
      store.dispatch('requestManagement/getOffers')
      store.dispatch('ico/updateIco')
    }
  })
}
