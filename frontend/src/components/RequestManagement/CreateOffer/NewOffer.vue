<template>
  <div class="newOffer">
    <div class="card card--newOffer">
      <div class="newOffer__close" @click="$emit('closeOfferCreation')"></div>
      <div class="title">Create Borrowing Offer</div>
      <div class="newOffer__numberInputs">
        <div class="input-group newOffer__credit">
          <input
            type="text"
            onkeydown="return (/^[0-9.]$/.test(event.key) ||
          event.key === 'Backspace')"
            id="newOffer__credit"
            class="form-control"
            v-model="credit"
            v-bind:class="{
              hasContent: credit.length > 0,
              invalidInput: invalidCredit,
            }"
          />
          <label for="newOffer__credit">Lend for (ETH)</label>
        </div>
        <div class="input-group newOffer__payback">
          <input
            type="text"
            onkeydown="return (/^[0-9.]$/.test(event.key) ||
          event.key === 'Backspace')"
            id="newOffer__payback"
            class="form-control"
            v-model="payback"
            v-bind:class="{
              hasContent: payback.length > 0,
              invalidInput: invalidPayback,
            }"
          />
          <label for="newOffer__payback">Payback (ETH)</label>
        </div>
      </div>
      <div class="input-group newOffer__description">
        <input
          type="text"
          id="newOffer__description"
          class="form-control"
          v-model="description"
          v-bind:class="{
            hasContent: description.length > 0,
            invalidInput: invalidDescription,
          }"
        />
        <label for="newOffer__description">Offer Description</label>
      </div>
      <div class="newOffer__button btn btn--form" @click="submit">Submit</div>
    </div>
  </div>
</template>

<script>
import { RequestManagementService } from "../../../services/requestManagement/RequestManagementService";

export default {
  data() {
    return {
      credit: "",
      payback: "",
      description: "",
      invalidCredit: false,
      invalidPayback: false,
      invalidDescription: false,
    };
  },
  methods: {
    async submit() {
      const createOfferReturn = await RequestManagementService.createOffer(
        this.credit,
        this.payback,
        this.description
      );

      // update error states
      this.invalidCredit = createOfferReturn.invalidCredit;
      this.invalidPayback = createOfferReturn.invalidPayback;
      this.invalidDescription = createOfferReturn.invalidDescription;

      // reset input on success
      if (
        !(this.invalidCredit || this.invalidPayback || this.invalidDescription)
      ) {
        this.credit = "";
        this.payback = "";
        this.description = "";
        this.invalidCredit = false;
        this.invalidPayback = false;
        this.invalidDescription = false;

        // close create request overlay
        this.$emit("closeOfferCreation");
      }
    },
  },
  watch: {
    credit() {
      this.invalidCredit = false;
    },
    payback() {
      this.invalidPayback = false;
    },
    description() {
      this.invalidDescription = false;
    },
  },
};
</script>

<style lang="scss">
@import "NewOffer";
</style>
