<template>
    <div>
        <div>VRepayment Date</div>
        <Datepicker class = "datepicker"></Datepicker>
    </div>
</template>
<script>
    import Datepicker from 'vuejs-datepicker'
    export default {
        name: 'app',
        components: {
            Datepicker
        }
    }
</script>