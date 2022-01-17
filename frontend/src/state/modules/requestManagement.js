import { RequestManagementService } from '../../services/requestManagement/RequestManagementService'
import { requestManagementListeners } from '../../services/requestManagement/RequestManagementListeners'

export default {
  namespaced: true,
  state: {
    requests: [],
    offers: [],
  },
  actions: {
    initializeRequestManagement() {
      requestManagementListeners()
    },
    async getRequests({ commit }) {
      const requests = await RequestManagementService.getRequests()
      commit('GET_REQUESTS', requests)
    },
    async getOffers({ commit }) {
      const offers = await RequestManagementService.getOffers()
      commit('GET_OFFERS', offers)
    },
  },
  mutations: {
    GET_REQUESTS(state, requests) {
      state.requests = requests
    },
    GET_OFFERS(state, offers) {
      state.offers = offers
    },
  },
}
