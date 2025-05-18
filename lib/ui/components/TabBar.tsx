import { CommonActions, ParamListBase, TabNavigationState } from '@react-navigation/native'
import React from 'react'
import { BottomNavigation } from 'react-native-paper'

// Define types compatible with React Navigation v7
type Route = {
  key: string;
  name: string;
  params?: object;
}

type BottomTabBarProps = {
  state: TabNavigationState<ParamListBase>;
  descriptors: Record<string, any>;
  navigation: any;
  insets: {
    top: number;
    right: number;
    bottom: number;
    left: number;
  };
}

const TabBar = (props: BottomTabBarProps) => (
  <BottomNavigation.Bar
    shifting
    navigationState={props.state}
    safeAreaInsets={props.insets}
    onTabPress={({ route, preventDefault }: { route: Route, preventDefault: () => void }) => {
      const event = props.navigation.emit({
        type: 'tabPress',
        target: route.key,
        canPreventDefault: true,
      })

      if (event.defaultPrevented) {
        preventDefault()
      } else {
        props.navigation.dispatch({
          ...CommonActions.navigate({ name: route.name }),
          target: props.state.key,
        })
      }
    }}
    renderIcon={({ route, focused, color }: { route: Route, focused: boolean, color: string }) => {
      const { options } = props.descriptors[route.key]
      if (options.tabBarIcon) {
        return options.tabBarIcon({ focused, color, size: 24 })
      }

      return null
    }}
    getLabelText={({ route }: { route: Route }) => {
      const { options } = props.descriptors[route.key]
      const label =
        options.tabBarLabel !== undefined
          ? options.tabBarLabel
          : options.title !== undefined
            ? options.title
            : route.name

      return label
    }}
  />
)

export default TabBar
