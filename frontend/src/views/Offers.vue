<template>
  <div class="offers">
    <div
      class="title offers__title"
      v-bind:class="{ offers__hidden: createOfferActive }"
      >{{ title }}</div
    >
    <div
      class="offers__create"
      v-if="$route.name === 'userBorrowOffers'"
      v-bind:class="{ offers__hidden: createOfferActive }"
      @click="createOfferActive = true"
      >Create Borrowing Offer</div
    >
    <div
      class="offers__children"
      v-bind:class="{ offers__hidden: createOfferActive }"
    >
      <router-view />
    </div>
    <CreateOffer
      class="offers__createForm"
      v-bind:class="{ offers__hidden: !createOfferActive }"
      v-on:closeOfferCreation="close"
    />
  </div>
</template>

<script>
import CreateOffer from '../components/RequestManagement/CreateOffer/NewOffer'

export default {
  components: {
    CreateOffer,
  },
  data() {
    return {
      title: '',
      createOfferActive: false
    }
  },
  methods: {
    setTitle() {
      this.title = 'My Offers'

      const route = this.$route.name
      if (route === 'allBorrowOffers') {
        this.title = 'Open Borrowing Offers'
      }
    },
    close() {
      this.createOfferActive = false
    },
  },
  mounted() {
    this.setTitle()
  },
  watch: {
    $route() {
      this.setTitle()
    },
  },
}
</script>

<style lang="scss">
@import '../util/scss/variables';

.offers {
  padding-top: 52px;
  display: grid;
  grid-template-columns: auto 49px 1007px 49px auto;
  grid-template-rows: 101px auto;
  justify-items: center;

  &__title {
    grid-row: 1;
    grid-column: 3;
    width: 100%;
    font-size: 38px;
    border-bottom: 2px solid #dfdfdf;
    margin-bottom: 29px;
    display: flex;
    justify-content: center;
    align-items: center;
    transition: all 0.3s ease-in-out;
  }

  &__create {
    grid-row: 1;
    grid-column: 3 / 5;
    justify-self: end;
    display: flex;
    justify-content: center;
    align-items: center;
    margin-bottom: 29px;
    font-size: 18px;
    columns: $primary-text-color;
    cursor: pointer;
    transition: all 0.3s ease-in-out;

    &::after {
      width: 32px;
      height: 32px;
      content: '';
      float: right;
      margin-left: 17px;
      background-image: url('../assets/circle_create.svg');
      background-repeat: no-repeat;
    }
  }

  &__children {
    grid-row: 2;
    grid-column: 3;
    transition: all 0.3s ease-in-out;
    width: 100%;
  }

  &__createForm {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    transition: all 0.3s ease-in-out;
  }

  &__hidden {
    visibility: hidden;
    opacity: 0;
  }
}
</style>
