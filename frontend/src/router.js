import Vue from 'vue'
import Router from 'vue-router'
import Home from './views/Home.vue'
import store from './state'

Vue.use(Router)

const router = new Router({
  mode: 'history',
  base: process.env.BASE_URL,
  routes: [
    {
      path: '/',
      name: 'home',
      component: Home,
    },
    {
      path: '/ico',
      name: 'ico',
      component: () => import(/* webpackChunkName: "ICO" */ './views/ICO.vue'),
      children: [
        {
          path: 'memberArea',
          name: 'memberArea',
          component: () =>
            import(
              /* webpackChunkName: "memberArea" */ './components/ProposalManagement/MemberControl'
            ),
        },
      ],
    },
    {
      path: '/requests',
      name: 'requests',
      component: () =>
        import(/* webpackChunkName: "Requests" */ './views/Requests.vue'),
      children: [
        {
          path: 'allRequests',
          name: 'allRequests',
          component: () =>
            import(
              /* webpackChunkName: "AllRequests" */ './components/RequestManagement/AllRequests/AllRequests'
            ),
        },
        {
          path: 'userRequests',
          name: 'userRequests',
          component: () =>
            import(
              /* webpackChunkName: "UserRequests" */ './components/RequestManagement/UserRequests/UserRequests'
            ),
        }
      ],
      beforeEnter(to, from, next) {
        if (to.path === '/requests') {
          next({ name: 'allRequests' })
        } else {
          next()
        }
      },
    },
    {
      path: '/offers',
      name: 'offers',
      component: () =>
        import(/* webpackChunkName: "Offers" */ './views/Offers.vue'),
      children: [
        {
          path: 'allBorrowOffers',
          name: 'allBorrowOffers',
          component: () =>
            import(
              /* webpackChunkName: "AllBorrowOffers" */ './components/RequestManagement/AllBorrowOffers/AllBorrowOffers'
            ),
        },
        {
          path: 'userBorrowOffers',
          name: 'userBorrowOffers',
          component: () =>
            import(
              /* webpackChunkName: "UserBorrowOffers" */ './components/RequestManagement/UserBorrowOffers/UserBorrowOffers'
            ),
        }
      ],
      beforeEnter(to, from, next) {
        if (to.path === '/offers') {
          next({ name: 'allBorrowOffers' })
        } else {
          next()
        }
      },
    },
  ],
})

router.beforeEach((to, from, next) => {
  if (store.state.ico.active) {
    if (to.path === '/' || to.path === '/ico') {
      next()
    } else {
      next({ name: 'home' })
    }
  } else {
    next()
  }
})

export default router
