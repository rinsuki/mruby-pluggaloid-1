# -*- coding: utf-8 -*-

require 'securerandom'

=begin rdoc
= リスナをまとめて管理するプラグイン

Pluggaloid::Listener や、 Pluggaloid::Filter をまとめて扱うための仕組み。
Pluggaloid::Plugin#add_event などの引数 _tags:_ に、このインスタンスを設定する。

== インスタンスの作成

Pluggaloid::Plugin#handler_tag を使って生成する。 Pluggaloid::HandlerTag の
_plugin:_ 引数には、レシーバ(Pluggaloid::Plugin)が渡される。
Pluggaloid::HandlerTag は、このプラグインの中でだけ使える。複数のプラグインのリスナ
をまとめて管理することはできない。

== リスナにタグをつける

Pluggaloid::Plugin#add_event または Pluggaloid::Plugin#add_event_filter の
_tags:_ 引数にこれのインスタンスを渡す。

== このタグがついたListenerやFilterを取得する

Enumerable をincludeしていて、リスナやフィルタを取得することができる。
また、
- Pluggaloid::HandlerTag#listeners で、 Pluggaloid::Listener だけ
- Pluggaloid::HandlerTag#filters で、 Pluggaloid::Filter だけ
を対象にした Enumerator を取得することができる

== このタグがついたリスナを全てdetachする

Pluggaloid::Plugin#detach の第一引数に Pluggaloid::HandlerTag の
インスタンスを渡すことで、そのHandlerTagがついたListener、Filterは全てデタッチ
される

=end
class Pluggaloid::HandlerTag < Pluggaloid::Identity
  include Enumerable

  # ==== Args
  # [name:] タグの名前(String | nil)
  def initialize(plugin:, **kwrest)
    super(**kwrest)
    @plugin = plugin
  end

  # このTagがついている Pluggaloid::Listener と Pluggaloid::Filter を全て列挙する
  # ==== Return
  # Enumerable
  def each(&block)
    if block_given?
      Enumerator.new do |y|
        listeners{|x| y << x }
        filters{|x| y << x }
      end.each(&block)
    else
      Enumerator.new do |y|
        listeners{|x| y << x }
        filters{|x| y << x }
      end
    end
  end

  # このTagがついている Pluggaloid::Listener を全て列挙する
  # ==== Return
  # Enumerable
  def listeners(&block)
    if block_given?
      listeners.each(&block)
    else
      @plugin.to_enum(:listeners).lazy.select{|l| l.tags.include?(self) }
    end
  end

  # このTagがついている Pluggaloid::Filter を全て列挙する
  # ==== Return
  # Enumerable
  def filters(&block)
    if block_given?
      filters.each(&block)
    else
      @plugin.to_enum(:filters).lazy.select{|l| l.tags.include?(self) }
    end
  end
end
