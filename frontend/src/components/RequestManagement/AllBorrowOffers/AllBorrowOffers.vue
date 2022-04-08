<template>
  <div class="allBorrowOffers">
    <div class="allBorrowOffers__title-wrapper">
      <div class="allBorrowOffers__title">Offers</div>
      <div class="allBorrowOffers__sortOptions">
        <div
          class="allBorrowOffers__sortOption"
          @click="getOffers"
          v-bind:class="{ 'allBorrowOffers__sortOption--active': !trustedOffers }"
          >All</div
        >
        <div
          class="allBorrowOffers__sortOption"
          @click="getTrustedOffers"
          v-bind:class="{ 'allBorrowOffers__sortOption--active': trustedOffers }"
          >Trusted</div
        >
      </div>
    </div>
    <div class="table__wrapper">
      <table class="table" v-if="filteredOffers.length > 0">
        <thead>
          <tr>
            <th class="table__head table__head--id"></th>
            <th class="table__head table__head--asker">Lender</th>
            <th class="table__head">Amount</th>
            <th class="table__head">Payback</th>
            <th class="table__head table__head--purpose">Purpose</th>
            <th class="table__head">Trusted</th>
            <th class="table__head table__head--option"></th>
          </tr>
        </thead>
        <tbody>
          <tr
            class="table__row"
            v-for="(item, index) in filteredOffers"
            :key="index"
          >
            <td class="table__data table__data--id">{{ index + 1 }}</td>
            <td class="table__data table__data--purpose">{{ item.lender }}</td>
            <td class="table__data">{{ item.askAmount }} ETH</td>
            <td class="table__data">{{ item.paybackAmount }} ETH</td>
            <td class="table__data">{{ item.purpose }}</td>
            <td class="table__data">
              <div
                class="table__status table__status--trusted"
                v-if="item.verifiedAsker"
                >Yes</div
              >
              <div class="table__status table__status--untrusted" v-else
                >No</div
              >
            </td>
            <td class="table__data">
              <div
                class="btn btn--table"
                @click="lend(item.address)"
                v-if="
                  (item.status === 'Ether Lent')
                "
                >Borrow</div
              >
              <div
                v-if="
                  (item.status === 'Waiting' &&
                    item.status !== 'Ether Lent')
                "
                >No deposit yet</div
              >
              <div
                v-if="
                  (item.status === 'Withdrawn')
                "
                >Lent</div
              >
              <div
                v-if="
                  (item.status === 'PaidBack')
                "
                >Paid Back</div
              >
            </td>
          </tr>
        </tbody>
      </table>
      <table class="table" v-else>
        <thead>
          <tr>
            <th class="table__head table__head--empty">Offers</th>
          </tr>
        </thead>
        <tbody>
          <tr class="table__row">
            <td class="table__data table__data--empty">No Offers Found</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import { Web3Service } from '../../../services/web3/Web3Service'
import { RequestManagementService } from '../../../services/requestManagement/RequestManagementService'

export default {
  computed: {
    ...mapState('requestManagement', ['offers']),
  },
  data() {
    return {
      filteredOffers: [],
      trustedOffers: false,
    }
  },
  methods: {
    lend(address) {
      RequestManagementService.withdraw(address)
    },
    async getOffers() {
      this.filteredOffers = []

      const user = await Web3Service.getUser()
      if (!user) {
        return
      }

      const locale = navigator.userLanguage || navigator.language
      const comparableAddress = String(user).toLocaleUpperCase(locale)

      this.offers.forEach((element) => {
        // if (
        //   !element.lent &&
        //   comparableAddress !== String(element.asker).toLocaleUpperCase(locale)
        // ) {
          this.filteredOffers.push(element)
        // }
      })

      // reflect display option internally
      this.trustedOffers = false
    },
    async getTrustedOffers() {
      this.filteredOffers = []

      const user = await Web3Service.getUser()
      if (!user) {
        return
      }

      const locale = navigator.userLanguage || navigator.language
      const comparableAddress = String(user).toLocaleUpperCase(locale)

      this.offers.forEach((element) => {
        if (
          !element.lent &&
          element.verifiedAsker &&
          comparableAddress !== String(element.asker).toLocaleUpperCase(locale)
        ) {
          this.filteredOffers.push(element)
        }
      })

      // reflect display option internally
      this.trustedOffers = true
    },
  },
  watch: {
    offers() {
      this.trustedOffers ? this.getTrustedOffers() : this.getOffers()
    },
  },
  mounted() {
    this.trustedOffers ? this.getTrustedOffers() : this.getOffers()
  },
}
</script>

<style lang="scss">
@import 'AllBorrowOffers';
</style>
